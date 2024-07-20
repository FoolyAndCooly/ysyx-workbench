ENTRY(_start)
PHDRS { text PT_LOAD; rodata PT_LOAD; data PT_LOAD; }

MEMORY {
  mrom : ORIGIN = 0x30000000, LENGTH = 1024K
  sram : ORIGIN = 0x80000000, LENGTH = 1024K
}

SECTIONS {
  /* _pmem_start and _entry_offset are defined in LDFLAGS */
  . = ORIGIN(mrom);
  .text : {
    *(entry)
    *(.text*)
  } > mrom AT>mrom : text
  etext = .;
  _etext = .;
  .rodata : {
    _srodata = .;
    *(.rodata*)
    _erodata = .;
  } > mrom AT> mrom : rodata
  .data : {
    _sdata = .;
    *(.sdata*)
    *(.data*)
    _edata = .;
  } > sram AT> mrom : data
  edata = .;
  _data = .;
  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > sram AT> mrom
  _stack_top = 0x80200000;
  . = _stack_top + 0x1ffff0;
  _stack_pointer = .;
  end = .;
  _end = .;
  _heap_start = _edata;
  _heap_end = _stack_pointer;
}
