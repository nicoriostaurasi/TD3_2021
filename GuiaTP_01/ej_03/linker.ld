SECTIONS
{

	. = 0x00007C00;
	.BinarioCopiado : AT (0x00068000)
	{}
	
	. = 0x00068000;
	.StackSegment : AT (0x00068000)
	{}

	. = 0xFFFF0000;
	.ROM_init : AT ( 0xFFFF0000 ) 
    {
	*(.start16);
	} /* coloco 0xFFFFF - 65535*/


	. = 0xFFFFFFF0;
	.resetVector : AT ( 0xFFFFFFF0 ) 
    {
	*(.resetVector)
	}
}