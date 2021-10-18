#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <fcntl.h>
#include "../inc/datos.h"

int crear_socket(int , int , int , int , struct sockaddr_in *, char* , char );
int atender_conexion(int,struct sockaddr_in *,char *);
int conectar_cliente(int , struct sockaddr_in *, char *, int , int );
void cargar_ip_cliente (struct sockaddr_in *, struct sockaddr_in *, struct sockaddr_in *);

/**
 * \fn int crear_socket (int DOMAIN, int TIPO, int PROTOCOL, int PUERTO, struct sockaddr_in *INFO_SOCKET, uint32_t DIR_IP)
 * \brief Funcion que crea un socket TCP o UDP.
 * \details Esta funcion crea un socket TCP o UDP, segun se especifique con SOCK_STREAM o SOCK_DGRAM. Crea
		 el socket y lo bindea a un puerto pasado tambien como parametro.
 * \param DOMAIN especifica el dominio del socket: AF_INET o AF_UNIX.
 * \param TIPO especifica si es SOCK_STREAM (TCP) o SOCK_DGRAM (UDP).
 * \param PROTOCOL especifica el protocolo para el tipo de socket, segun el dominio. Dejando "0", hacemos que
	   el sistema elija el protocolo mas acorde.
 * \param PUERTO especifica el puerto al cual "bindearemos" el socket creado.
 * \param *INFO_SOCKET es un puntero a una estructura del tipo sockaddr_in donde almacenaremos los datos del
	   socket creado.
 * \param DIR_IP con esto lo asinamos una direccion IP al socket. Con la macro INADDR_ANY hacemos que el
	   sistema seleccione la IP local (localhost o loopback, 127.0.0.1) o la IP asignada por el DHCP del
	   ISP que tengamos, o el router, o switch.
 * \param ROL_S especifica el rol del socket, si sera cliente o servidor.
 * \return int retorna el identificador del socket creado.
 * \author	Luciano Ferreyro
**/	

int crear_socket(int DOMINIO_S, int TIPO_S, int PROTOCOL_S, int PUERTO, struct sockaddr_in *INFO_SOCKET, char* DIR_IP, char ROL_S)
	{
	int socket_obtenido, yes = 1;
	struct sockaddr_in AUX;

	if ((socket_obtenido = socket(DOMINIO_S,TIPO_S,PROTOCOL_S)) == -1) 	//Ubicamos un socket util
		{
		perror("socket");
		return (-1);
		}
	
	if(setsockopt(socket_obtenido,SOL_SOCKET,SO_REUSEADDR,&yes,sizeof(int)) == -1)
		{
		perror("setsockopt");
		return(-1);
		}

	//printf("\nCreacion exitosa del socket.");
	
	if(ROL_S) //Si es Server
		{
		bzero(INFO_SOCKET,sizeof(*INFO_SOCKET));	//Inicializo en cero.
		(*INFO_SOCKET).sin_family = DOMINIO_S;		//Asignamos el protocolo de comunicacion.
		(*INFO_SOCKET).sin_port = htons(PUERTO);  	//Asignamos el puerto.
		(*INFO_SOCKET).sin_addr.s_addr = htonl(INADDR_ANY); //Tomamos cualquier IP de la maquina. Veremos que aparece: 0.0.0.0, pero eso implica para 
														    //el socket, que se usaran cualquier de las direccion: 127.0.0.1 (localhost o loopback) o la ip
														    //que el ISP o el DHCP server de una red, le haya asignado a nuestra PC.
		bzero(((*INFO_SOCKET).sin_zero),8);		
			
		//printf("\nSocket servidor...");

		if (bind(socket_obtenido,(struct sockaddr*)INFO_SOCKET, sizeof(struct sockaddr_in)) == -1) 	//Le asignamos un puerto al socket obtenido.
			{
			close(socket_obtenido);
			perror("bind");
			return (-1);
			}
		}
	else
		{
		//printf("\nSocket cliente...");
		
		// if(TIPO_S == SOCK_DGRAM)
		// 	{
		// 	bzero(&INFO_SOCKET,sizeof(*INFO_SOCKET));		//Inicializo en cero.
		// 	(*INFO_SOCKET).sin_family = DOMINIO_S;		//Asignamos el protocolo de comunicacion.
		// 	(*INFO_SOCKET).sin_port = htons(PUERTO);  	//Asignamos el puerto.
		// 	(*INFO_SOCKET).sin_addr.s_addr = inet_addr(DIR_IP); 
		// 	bzero(((*INFO_SOCKET).sin_zero),8);	

			// if (bind(socket_obtenido,(struct sockaddr*)&AUX, sizeof(struct sockaddr_in)) == -1) 
			// 	{
			// 	close(socket_obtenido);
			// 	perror("bind");
			// 	return (-1);
			// 	}			
			//}
		}
	
	//printf("\nAsignacion exitosa del puerto e IP del socket");
	fflush(stdout);		
	return (socket_obtenido);
		
	}

/**
 * \fn int atender_conexion(int SOCKET, (struct sockaddr*)INFO_SOCKET_CLT,unsigned char *DATO)
 * \brief Funcion que atiende una conexion TCP con un cliente.
 * \details Esta funcion se encarga de realizar un handshake entre el servidor y el cliente nuevo. Hace 
		 el accept().
 * \param SOCKET Socket a traves del cual se hace el connect-accept
 * \param *INFO_SOCKET_CLT se almacenan los datos del cliente que se conecto.
 * \param *datos puntero al dato (string generalmente, por ser TCP) a enviar.
 * \return int Ante exito, retorna el socket por donde se realiza la comunicacion. Retorna -1 si hubo error.
 * \author	Luciano Ferreyro
 * 
 **/


int atender_conexion(int SOCKET,struct sockaddr_in *INFO_SOCKET_CLT, char *DATO)
	{
	socklen_t socket_size;
	int socket_nuevo;
	
	socket_size = sizeof(INFO_SOCKET_CLT);
	//Conexion TCP	
	if((socket_nuevo = accept(SOCKET,(struct sockaddr*)INFO_SOCKET_CLT, &socket_size)) == -1)
		{
		if (errno != EINTR)
		  perror("accept");
		return (-1);	
		}
	//Si se supera al condicional, entonces quiere decir que se pudo efectuar una conexion. Fue aceptada.
	//printf("\nNuevo cliente conectado. Socket OK!\n\n");
	if (send(socket_nuevo, DATO, strlen(DATO), 0) == -1)
		{
		perror("send");		
		return (-1);
		}			
	return (socket_nuevo);
	}

/**
 * \fn int conectar_cliente(int SOCKET, (struct sockaddr*)INFO_SOCKET,char *DIRECCION, int PORT, int DOMINIO)
 * \brief Funcion que conecta a un cliente.
 * \details Esta funcion se encarga de realizar un la conexion TCP entre el cliente y el servidor.
 * \param SOCKET Socket a traves del cual se hace el connect-accept
 * \param *INFO_SOCKET se almacenan los datos del servidor donde nos conectaremos.
 * \param *DIRECCION es la direccion IP del servidor.
 * \param PORT es el puerto a traves del cual se realizara la conexion TCP.
 * \param DOMINIO es el dominio de la conxion: AF_INET o AF_UNIX
 * \return int Ante exito, retorna 1, y ante un error de connect devuelve -1.
 * \author	Luciano Ferreyro
**/

int conectar_cliente(int SOCKET, struct sockaddr_in *INFO_SOCKET, char *DIRECCION, int PORT, int DOMINIO)
	{
	//Aca deberia hacer un bind, si pretendo enviar cosas por el cliente. Por ahora no hago nada, solo recibo desde el servidor.
	//Cargo la estructura del socket del Server
	bzero(INFO_SOCKET, sizeof(*INFO_SOCKET));
	(*INFO_SOCKET).sin_family = DOMINIO;
	(*INFO_SOCKET).sin_port = htons(PORT);
	(*INFO_SOCKET).sin_addr.s_addr = inet_addr(DIRECCION); //Ingresada por el usuario
	bzero((*INFO_SOCKET).sin_zero,8);	

	if(connect(SOCKET,(struct sockaddr *)INFO_SOCKET,sizeof(struct sockaddr_in)) == -1)
		{
		//Si no pudo conectarse, cerramos el SOCKET ya que no hace falta
		close(SOCKET);
		perror("\nError en el cliente: connect");
		return (-1);
		}
	return 1;	
	}

/**
 * \fn int cargar_ip_cliente (struct sockaddr_in *INFO_SOCKET_TCP, struct sockaddr_in *INFO_SOCKET_UDP, struct sockaddr_in *INFO_SOCKET_UDP_DST)
 * \brief Funcion que carga parametros.
 * \details Esta funcion se encarga de preparar la estructura del tipo sockaddr_in con la IP (en particular) que utilizara 
  	     el servidor (en este caso) para enviar datos utilizando la funcion sendto.
 * \param SOCKET Socket a traves del cual se hace el connect-accept
 * \param *INFO_SOCKET se almacenan los datos del servidor donde nos conectaremos.
 * \param *DIRECCION es la direccion IP del servidor.
 * \param PORT es el puerto a traves del cual se realizara la conexion TCP.
 * \param DOMINIO es el dominio de la conxion: AF_INET o AF_UNIX
 * \return int Ante exito, retorna 1, y ante un error de connect devuelve -1.
 * \author	Luciano Ferreyro
**/

void cargar_ip_cliente (struct sockaddr_in *INFO_SOCKET_TCP, struct sockaddr_in *INFO_SOCKET_UDP, struct sockaddr_in *INFO_SOCKET_UDP_DST)
	{
	bzero(INFO_SOCKET_UDP_DST, sizeof(*INFO_SOCKET_UDP_DST));
	(*INFO_SOCKET_UDP_DST).sin_addr.s_addr = (*INFO_SOCKET_TCP).sin_addr.s_addr;		
	(*INFO_SOCKET_UDP_DST).sin_family = (*INFO_SOCKET_UDP).sin_family;
	(*INFO_SOCKET_UDP_DST).sin_port = (*INFO_SOCKET_UDP).sin_port;
	bzero((*INFO_SOCKET_UDP_DST).sin_zero,8);
	
	}
	
	







