ENTRY(_start)
PHDRS { text1 PT_LOAD; text2 PT_LOAD; rodata PT_LOAD; data PT_LOAD; }

MEMORY {
  flash : ORIGIN = 0x30000000, LENGTH = 16M
  psram : ORIGIN = 0x80000000, LENGTH = 4M
}

SECTIONS {
  /* _pmem_start and _entry_offset are defined in LDFLAGS */
  . = ORIGIN(flash);
  .text1 : {
    *(entry)
    *(._trm_init)
    *(.bootload)
  } > flash AT>flash : text1

  .text2 : {
    _stext2_virt = .;
    *(.text*)
    _etext2_virt = .;
  } > psram AT>flash : text2
  _stext2_phys = LOADADDR(.text2);

  .rodata : {
    _srodata_virt = .;
    *(.srodata*)
    *(.rodata*)
    _erodata_virt = .;
  } > psram AT> flash : rodata
  _srodata_phys = LOADADDR(.rodata);

  .data : {
    _sdata_virt = .;
    *(.sdata*)
    *(.data*)
    _edata_virt = .;
  } > psram AT> flash : data
  _sdata_phys = LOADADDR(.data);

  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > psram AT> flash

  _stack_top = 0x80200000;
  . = _stack_top + 0x1ffff0;
  _stack_pointer = .;
  _heap_start = _edata_virt;
  _heap_end = _stack_pointer;
}
