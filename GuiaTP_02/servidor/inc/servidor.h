#define ARES_2G                     2.0f/32768.0f
#define GYR_250                     250.0f/32768.0f


int AtiendeCliente(int socket, struct sockaddr_in addr,char* shm_addr, int sem_set_id,struct sembuf sb);
int DemasiadosClientes(int socket, struct sockaddr_in addr);