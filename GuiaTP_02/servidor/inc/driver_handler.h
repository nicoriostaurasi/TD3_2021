void colector_sensor(int* driver_pipe,char* shm_addr, int sem_set_id,struct sembuf sb);
void realocacion(int* vector,int elementos);
 int filtro(int* buffer,int largo, int muestra);
void rellenar(int* buffer,int largo);