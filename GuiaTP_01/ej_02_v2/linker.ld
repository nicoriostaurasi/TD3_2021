SECTIONS
{
	. = 0xFFFF0000;
	.ROM_init : AT ( 0xFFFF0000 ) 
    {*(.ROM_init);*(.start16);} /* coloco 0xFFFFF - 65535*/

	. = 0xFFFFFFF0;
	.resetVector : AT ( 0xFFFFFFF0 ) 
    {*(.resetVector)}
}