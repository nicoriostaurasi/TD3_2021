extern int crear_socket(int , int , int , int , struct sockaddr_in *, char* , char );
extern int atender_conexion(int,struct sockaddr_in *,char *);
extern int conectar_cliente(int , struct sockaddr_in *, char *, int , int );
extern void cargar_ip_cliente (struct sockaddr_in *, struct sockaddr_in *, struct sockaddr_in *);
