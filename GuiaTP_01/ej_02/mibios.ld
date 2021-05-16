SECTIONS
{
	. = 0xFFFF0000;
	.ROM_init : AT ( 0xFFFF0000 ) {*(.ROM_init)} /* coloco 0xFFFFF - 65535*/

	. = 0xFFFFFFF0;	/*'.' es el location counter. 
                    Al inicio del comando SECTIONS su valor es 0.
                    Se incrementa con el tamaño de las secciones.
                    Su valor corresponde a Direcciones Virtuales*/
	.resetVector : AT ( 0xFFFFFFF0 ) {*(.resetVector)}		

}
