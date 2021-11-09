void colector_sensor(int* driver_pipe,char* shm_addr, int sem_set_id);
void realocacion(int* vector,int elementos);
 int filtro(int* buffer,int largo, int muestra);
void rellenar(int* buffer,int largo);
void sem_lock(int sem_set_id);
void sem_unlock(int sem_set_id);
