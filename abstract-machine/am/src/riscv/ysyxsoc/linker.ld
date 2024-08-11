ENTRY(_start)
PHDRS { fsbl PT_LOAD; ssbl PT_LOAD; text PT_LOAD; rodata PT_LOAD; data PT_LOAD; }

MEMORY {
  flash : ORIGIN = 0x30000000, LENGTH = 16M
  sdram : ORIGIN = 0xa0000000, LENGTH = 4M
}

SECTIONS {
  /* _pmem_start and _entry_offset are defined in LDFLAGS */
  . = ORIGIN(flash);
  .fsbl : {
    *(entry)
    *(.bootload)
    *(.fsbl)
  } > flash AT>flash : fsbl

  .ssbl : {
    _sssbl_virt = .;
    *(.bootload)
    *(.ssbl)
    _essbl_virt = .;
  } > sdram AT>flash : ssbl
  _sssbl_phys = LOADADDR(.ssbl);

  .text : {
    _stext_virt = .;
    *(._trm_init)
    *(.text*)
    _etext_virt = .;
  } > sdram AT>flash : text
  _stext_phys = LOADADDR(.text);

  .rodata : {
    _srodata_virt = .;
    *(.srodata*)
    *(.rodata*)
    _erodata_virt = .;
  } > sdram AT> flash : rodata
  _srodata_phys = LOADADDR(.rodata);

  .data : {
    _sdata_virt = .;
    *(.sdata*)
    *(.data*)
    _edata_virt = .;
  } > sdram AT> flash : data
  _sdata_phys = LOADADDR(.data);

  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > sdram AT> flash

  _stack_top = 0xa0200000;
  . = _stack_top + 0x1ffff0;
  _stack_pointer = .;
  _heap_start = _edata_virt;
}
