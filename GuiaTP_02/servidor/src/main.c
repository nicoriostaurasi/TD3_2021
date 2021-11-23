/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Archivo principal del servidor, se encarga de levantar a los hijos y crear los demas recursos
 * @version 0.1
 * @date 02-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include "../inc/main.h"

volatile int file_update = 0;

volatile int activated = 1; /*Variable del superlazo*/

volatile int childcount = 0;

void handle_sigkill(int s)
{
    printf("[SERVER]: Control C por consola\n");
    activated = 0;
    return;
}

void handle_sigusr1(int s)
{
    printf("[SERVER]: señal sigusr1\n");
    return;
}

void handle_sigusr2(int s)
{
    file_update = 1;
    return;
}

void handle_sigchild(int s)
{
    int pidstatus; /*Variable que revisa un hijo finalizo ejecución*/
    int childpid;
    childpid = waitpid(0, &pidstatus, WNOHANG);
    if (childpid > 0)
    {
        childcount--; /* Se acaba de morir un hijo */
        printf("[SERVER]: Se desconecto un cliente PID:%d \n", childpid);
        printf("[SERVER]: Hijos Actuales:%d \n", childcount);
    }
    return;
}

int main()
{
    printf("\n");
    printf(" \\o/ \n");
    printf("[SERVER]: Hola mundo\n");
    printf("[SERVER]: Bienvenido al Servidor de TD3\n");
    printf("[SERVER]: Momentaneamente me encuentro corriendo en el PID Nº:%d\n", getpid());
    printf("\n");

    int aux_control = 0;
    int clientes_maximos = 4;       /*Numero de Clientes*/
    int socket_host;                /*FD del HOST*/
    struct sockaddr_in client_addr; /*Address Cliente*/
    struct sockaddr_in my_addr;     /*Address Propia*/

    socklen_t size_addr = 0;
    int socket_client; /*FD del Cliente Nuevo*/
    struct shmid_ds shm_desc;

    int var_backlog = CONEC_DEF;
    int exitcode;       /*Codigo de salida*/
    int childpid;       /*Variable de PID que atiende clientes concurrentes*/
    int PID_driver;     /*PID del proceso driver*/
    int driver_pipe[2]; /*Pipe para la comunicacion con el proceso driver*/
    int shm_id;         /*ID de la Shared Memory*/
    char *shm_addr;     /*Puntero a la Shared Memory*/

    fd_set rfds;       /* Conjunto de descriptores a vigilar */
    struct timeval tv; /* Para el timeout del accept */

    int sem_set_id; /*ID del semaforo*/
    struct sembuf sb;
    union smun arg;
    //----------------------------------------------------------------------------------------
    /*Alojo la SHMEM 512 bytes*/
    shm_id = shmget(IPC_PRIVATE, 512, IPC_CREAT | IPC_EXCL | 0600);
    if (shm_id == -1)
    {
        printf("[SERVER]: Error al crear un segmento de memoria compartida\n");
        exit(1);
    }

    /*Mapeo la dirección de la SHMEM al espacio de direccionamiento del padre*/
    shm_addr = shmat(shm_id, NULL, 0);
    if (!shm_addr)
    {
        printf("[SERVER]: Error al direccionar el segmento de memoria compartida\n");
        exit(1);
    }

    /*Vacio la primer posición*/
    *shm_addr = 0;

    //----------------------------------------------------------------------------------------
    //Creo el semaforo
    sem_set_id = semget(SEM_ID, 2, IPC_CREAT | 0600);
    if (sem_set_id == -1)
    {
        printf("[SERVER]: Error al solicitar el semaforo\n");
        exit(1);
    }

    sb.sem_op = 1;
    sb.sem_flg = 0;
    arg.val = 1;

    for (sb.sem_num = 0; sb.sem_num < 2; sb.sem_num++)
    {
        if (semop(sem_set_id, &sb, 1) == -1)
        {
            semctl(sem_set_id, 0, IPC_RMID);
        }
    }
    //----------------------------------------------------------------------------------------
    /*Creo el Pipe entre el proceso Padre y mi hijo lector de driver*/
    if (pipe(driver_pipe) == -1)
    {
        printf("[SERVER]: Error al crear el PIPE\n");
        exit(1);
    }

    PID_driver = fork();

    if (PID_driver == 0)
    {
        signal(SIGINT, SIG_IGN);
        printf("[SERVER]: Se creo un hijo para leer el driver %d\n", getpid());
        colector_sensor(driver_pipe, shm_addr, sem_set_id, sb);
        exit(0);
    }

    //----------------------------------------------------------------------------------------
    /*Inicializo el Socket*/
    socket_host = socket(AF_INET, SOCK_STREAM, 0);
    if (socket_host == -1)
    {
        printf("[SERVER]: No puedo inicializar el socket\n");
        exit(1);
    }

    /*Llamo al lector de configuracion*/
    if (Lector_CFG(&clientes_maximos, &var_backlog, driver_pipe) == -1)
    {
        printf("[SERVER]: Error en la lectura del archivo de configuración\n");
    }
    else
    {
        printf("[SERVER]: Cargado el Archivo de Configuración\n");
        printf("[SERVER]: Backlog %d, Clientes Máximos %d\n", var_backlog, clientes_maximos);
    }

    /*Inicializo el Puerto*/
    my_addr.sin_family = AF_INET;
    my_addr.sin_port = htons(PORT);
    my_addr.sin_addr.s_addr = INADDR_ANY;

    if (bind(socket_host, (struct sockaddr *)&my_addr, sizeof(my_addr)) == -1)
    {
        /* desatachamos la shmem de nuestro espacio de direccionamiento*/
        if (shmdt(shm_addr) == -1)
        {
            printf("[SERVER]: Error al desatachar la shmem\n");
        }

        /* desalojamos el segmento de memoria compartida*/
        if (shmctl(shm_id, IPC_RMID, &shm_desc) == -1)
        {
            printf("[SERVER]: Error al desalojar el segmento de shmem\n");
        }

        if (semctl(sem_set_id, 0, IPC_RMID) == -1)
        {
            printf("[SERVER]: Error al desalojar el semaforo\n");
        }

        close(socket_host);

        printf("[SERVER]: No se pudo bindear el puerto\n");

        exit(1);
    }

    if (listen(socket_host, var_backlog) == -1)
    {
        /* desatachamos la shmem de nuestro espacio de direccionamiento*/
        if (shmdt(shm_addr) == -1)
        {
            printf("[SERVER]: Error al desatachar la shmem\n");
        }

        /* desalojamos el segmento de memoria compartida*/
        if (shmctl(shm_id, IPC_RMID, &shm_desc) == -1)
        {
            printf("[SERVER]: Error al desalojar el segmento de shmem\n");
        }

        if (semctl(sem_set_id, 0, IPC_RMID) == -1)
        {
            printf("[SERVER]: Error al desalojar el semaforo\n");
        }

        close(socket_host);

        printf("[SERVER]: No se puede escuchar el puerto especificado\n");
        exit(1);
    }
    size_addr = sizeof(struct sockaddr_in);
    //----------------------------------------------------------------------------------------

    printf("[SERVER]: Se ha configurado el socket en IP: 192.168.1.48 y Puerto: %d\n", (int)ntohs(my_addr.sin_port));
    printf("[SERVER]: Ya se puede escuchar a los multiples clientes\n");

    struct sigaction muerte;
    muerte.sa_handler = handle_sigkill;
    muerte.sa_flags = 0;
    sigemptyset(&muerte.sa_mask);
    sigaction(SIGINT, &muerte, NULL);

    struct sigaction lectura;
    lectura.sa_handler = handle_sigusr2;
    lectura.sa_flags = 0;
    sigemptyset(&lectura.sa_mask);
    sigaction(SIGUSR2, &lectura, NULL);

    struct sigaction muere_hijo;
    muere_hijo.sa_handler = handle_sigchild;
    muere_hijo.sa_flags = SA_RESTART;
    sigemptyset(&muere_hijo.sa_mask);
    sigaction(SIGCHLD, &muere_hijo, NULL);

    signal(SIGUSR1, SIG_IGN);

    while (activated)
    {

        if (file_update == 1)
        {
            aux_control = 0;
            file_update = 0;
            printf("[SERVER]: SIGNAL SIGUSR 2, Actualizo Configuración\n");
            if (Lector_CFG(&clientes_maximos, &var_backlog, driver_pipe) == -1)
            {
                printf("[SERVER]: Error en la lectura del archivo de configuración\n");
            }
            else
            {
                printf("[SERVER]: Cargado el Archivo de Configuración\n");
                printf("[SERVER]: Backlog %d, Clientes Máximos %d\n", var_backlog, clientes_maximos);
            }
        }

        if (activated == 0)
        {
            break;
        }

        if ((socket_client = accept(socket_host, (struct sockaddr *)&client_addr, &size_addr)) != -1)
        {
            switch (childpid = fork())
            {
            case -1: /* Error con el FORK*/
            {
                printf("[SERVER]: No se puede crear el proceso hijo\n");
                break;
            }

            case 0: /* Somos proceso hijo */
            {
                signal(SIGINT, SIG_DFL);
                signal(SIGUSR1, SIG_DFL);
                signal(SIGUSR2, SIG_IGN);
                signal(SIGCHLD, SIG_IGN);
                if (childcount < clientes_maximos)
                {
                    printf("[SERVER]: Se ha conectado %s por su puerto %d\n", inet_ntoa(client_addr.sin_addr), client_addr.sin_port);
                    exitcode = AtiendeCliente(socket_client, client_addr, shm_addr, sem_set_id, sb);
                    close(socket_client);
                }
                else
                {
                    printf("[SERVER]: Se ha intentado conectar %s por su puerto %d, pero no hay lugar para otro cliente"
                           "\n",
                           inet_ntoa(client_addr.sin_addr), client_addr.sin_port);
                    exitcode = DemasiadosClientes(socket_client, client_addr);
                }

                exit(exitcode); /* Código de salida */
                break;
            }

            default: /* Somos proceso padre */
            {
                printf("[SERVER]: Linux dame un hijo por favor: \n");
                printf("[LINUX]: Aqui tiene señor %d, cliente: %s puerto: %d. Hijo N°:%d\n", childpid, inet_ntoa(client_addr.sin_addr), client_addr.sin_port, childcount);
                childcount++; /* Acabamos de tener un hijo */
                printf("[SERVER]: Contador de hijos %d\n", childcount);
                close(socket_client); /* Nuestro hijo se las apaña con el cliente que
                             entró, para nosotros ya no existe. */
                break;
            }
            }
        }
        else
        {
            if (aux_control != 0)
            {
                printf("[SERVER]: ERROR AL ACEPTAR LA CONEXIÓN\n");
                aux_control = 1;
            }
        }
    }

    /* desatachamos la shmem de nuestro espacio de direccionamiento*/
    if (shmdt(shm_addr) == -1)
    {
        printf("[SERVER]: Error al desatachar la shmem\n");
    }

    /* desalojamos el segmento de memoria compartida*/
    if (shmctl(shm_id, IPC_RMID, &shm_desc) == -1)
    {
        printf("[SERVER]: Error al desalojar el segmento de shmem\n");
    }

    if (semctl(sem_set_id, 0, IPC_RMID) == -1)
    {
        printf("[SERVER]: Error al desalojar el semaforo\n");
    }
    printf("[SERVER]: Liberados recursos, fin de ejecución.\n");
    if (close(socket_host) == -1)
    {
        printf("[SERVER]: Error al cerrar el socket\n");
    }
    close(driver_pipe[0]);
    close(driver_pipe[1]);
    kill(PID_driver, SIGUSR2);
    kill(0, SIGALRM);

    return 0;
}
