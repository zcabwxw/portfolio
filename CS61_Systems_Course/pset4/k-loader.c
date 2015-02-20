#include "x86.h"
#include "elf.h"
#include "lib.h"
#include "kernel.h"

// k-loader.c
//
//    Load a weensy application into memory from a RAM image.

#define SECTORSIZE              512

extern uint8_t _binary_obj_p_allocator_start[];
extern uint8_t _binary_obj_p_allocator_end[];
extern uint8_t _binary_obj_p_allocator2_start[];
extern uint8_t _binary_obj_p_allocator2_end[];
extern uint8_t _binary_obj_p_allocator3_start[];
extern uint8_t _binary_obj_p_allocator3_end[];
extern uint8_t _binary_obj_p_allocator4_start[];
extern uint8_t _binary_obj_p_allocator4_end[];
extern uint8_t _binary_obj_p_fork_start[];
extern uint8_t _binary_obj_p_fork_end[];
extern uint8_t _binary_obj_p_forkexit_start[];
extern uint8_t _binary_obj_p_forkexit_end[];

struct ramimage {
    void* begin;
    void* end;
} ramimages[] = {
    { _binary_obj_p_allocator_start, _binary_obj_p_allocator_end },
    { _binary_obj_p_allocator2_start, _binary_obj_p_allocator2_end },
    { _binary_obj_p_allocator3_start, _binary_obj_p_allocator3_end },
    { _binary_obj_p_allocator4_start, _binary_obj_p_allocator4_end },
    { _binary_obj_p_fork_start, _binary_obj_p_fork_end },
    { _binary_obj_p_forkexit_start, _binary_obj_p_forkexit_end }
};

static int copyseg(proc* p, const elf_program* ph, const uint8_t* src);

// program_load(p, program_id)
//    Load the code corresponding to program `programnumber` into the process
//    `p` and set `p->p_registers.reg_eip` to its entry point. Calls
//    `physical_page_alloc` to allocate virtual memory for `p` as required.
//    Returns 0 on success and -1 on failure (e.g. out-of-memory).


int program_load(proc* p, int program_id) {
    // calculate nprograms
    int nprograms = sizeof(ramimages) / sizeof(ramimages[0]);
    // check program_id
    assert(program_id >= 0 && program_id < nprograms);
    // talk with the elves
    elf_header* eh = (elf_header*) ramimages[program_id].begin;
    assert(eh->e_magic == ELF_MAGIC);

    // load each loadable program segment into memory
    elf_program* ph = (elf_program*) ((const uint8_t*) eh + eh->e_phoff);
    for (int i = 0; i < eh->e_phnum; ++i)
        if (ph[i].p_type == ELF_PTYPE_LOAD)
            if (copyseg(p, &ph[i], (const uint8_t*) eh + ph[i].p_offset) < 0)
                return -1;
        

    // set the entry point from the ELF header
    p->p_registers.reg_eip = eh->e_entry;
        // log_printf("end program_load\n");
    return 0;
}


// copyseg(p, ph, src)
//    Load an ELF segment at virtual address `ph->p_va` in process `p`. Copies
//    `[src, src + ph->p_filesz)` to `dst`, then clears
//    `[ph->p_va + ph->p_filesz, ph->p_va + ph->p_memsz)` to 0.

//    Calls `physical_page_alloc` to allocate pages and `virtual_memory_map`
//    to map them in `p->p_pagetable`. Returns 0 on success and -1 on failure.
static int copyseg(proc* p, const elf_program* ph, const uint8_t* src) {
 
    // get the virutal address of the copy segment.
    uintptr_t va = (uintptr_t) ph->p_va;
    
    // get the end of the file, get end of memory. 
    uintptr_t end_file = va + ph->p_filesz, end_mem = va + ph->p_memsz;
    
    va &= ~(PAGESIZE - 1);              // round to page boundary
    
    
    // allocate memory
    for (uintptr_t page_va = va; page_va < end_mem; page_va += PAGESIZE) {
        if (physical_page_alloc(page_va, p->p_pid) < 0)
            return -1;
                     
         virtual_memory_map(p->p_pagetable, page_va, page_va,
                         PAGESIZE, PTE_P|PTE_W|PTE_U);
      
    }
    // ensure new memory mappings are active
    lcr3((uintptr_t) p->p_pagetable);
    
    // copy data from source into va. size is end_file - va. 
    memcpy((uint8_t*) va, src, end_file - va);
    
    // memset this. 
    memset((uint8_t*) end_file, 0, end_mem - end_file);
    
    if ((ph->p_flags & ELF_PFLAG_WRITE) == 0)
    {
        // iterate through all pages in segment using virtual addresses. 
        // are these all the pages containing the elf program? 
        for (uintptr_t page_va = va; page_va < end_mem; page_va += PAGESIZE) {

           virtual_memory_map(p->p_pagetable, page_va, page_va,
                           PAGESIZE, PTE_P|PTE_U);
        }
    }
    
    
    return 0;
}
