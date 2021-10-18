#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket
import sys
import time
import subprocess
import argparse
import csv
import os
import types
import threading
from sys import stdin
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np
import datetime as dt

dummy_os = os.system("clear")
	

client_socket_tcp = 0
client_socket_udp = 0
data = 0
data_sensor = 0
time_interleave_aux = 0
plot_close_event = 0
x = 0

PUERTO_TCP_COMU = 23400
PUERTO_UDP_1 = 23401
PUERTO_UDP_2 = 23402
TAM_MAX_DAT = 1024

ax_1 = []
ax_2 = []
ax_3 = []
ax_4 = []

def animate(i, client_socket, ax, ax_2, xs, ys, xs_2, ys_2):
	global time_interleave_aux

	# Aca va la comunicacion con el servidor, porque se llama a este metodo y no se sale hasta el final
	data_sensor, address_server = client_socket.recvfrom(TAM_MAX_DAT)
	
	# data_sensor = data
	print('[ Cliente ]-$ Recibiendo: %s\t| %d' %(data_sensor.decode(),len(data_sensor.decode())+1))

	if time_interleave_aux == 0:
		time_interleave_aux = 1
		# Add x and y to lists
		#xs.append(dt.datetime.now().strftime('%H:%M:%S.%f'))
		ys.append(data_sensor.decode())
		# Limit x and y lists to 20 items
		#xs = xs[-20:]
		ys = ys[-20:]
		# Draw x and y lists
		ax.clear()
		# ax.plot(xs, ys,'b--')	
		ax.plot(ys,'b--')	

	else:
		time_interleave_aux = 0
		# Add x and y to lists
		xs_2.append(dt.datetime.now().strftime('%H:%M:%S.%f'))
		ys_2.append(data_sensor.decode())
		# Limit x and y lists to 20 items
		xs_2 = xs_2[-20:]
		ys_2 = ys_2[-20:]
		# Draw x and y lists
		ax_2.clear()
		ax_2.plot(ys_2,'r--')	
		
    # Format plot
	plt.xticks(rotation=45, ha='right')
	plt.subplots_adjust(bottom=0.30)
	plt.title('Medición acelerómetro')
	plt.ylabel('Amplitud [a.u.]')
	plt.xlabel('Tiempo [s]')
	plt.grid()

def handle_close(evt):
	global plot_close_event
	plot_close_event = 1


def real_time_plot(x_vec,y1_data,y2_data,y3_data,y4_data,line1,line2,line3,line4,pause_time=0.1):
	global ax_1
	global ax_2
	global ax_3
	global ax_4

	if line1==[]:
		
		plt.ion()
		fig = plt.figure(figsize=(24,15))
		# Esto es para trapear cuando se cierre el plot, y asi terminar la aplicación cliente
		fig.canvas.mpl_connect('close_event', handle_close)
		fig.canvas.manager.set_window_title('TD3 - UTN - FRBA - 2021')

		plt.suptitle('Trabajo Práctico - 2ºC - 2021')
		# plot 1
		ax_1 = fig.add_subplot(231)		
		line1, = ax_1.plot(x_vec,y1_data,'b--',alpha=0.8,label='Proceso 1')             
		
		plt.ylabel('Amplitud [a.u]')
		plt.xlabel('Muestra')
		plt.title('Mediciones del Acelerómetro')
		plt.grid()
		plt.legend(loc='upper right')

		# plot 2
		ax_2 = fig.add_subplot(232)

		line2, = ax_2.plot(x_vec,y2_data,'r--',alpha=0.8,label='Proceso 2') 
		plt.ylabel('Amplitud [a.u]')
		plt.xlabel('Muestra')
		plt.title('Mediciones del Giróscopo')
		plt.grid()
		plt.legend(loc='upper right')

		# plot 3
		ax_3 = fig.add_subplot(233)

		line3, = ax_3.plot(x_vec,y3_data,'g--',alpha=0.8,label='Proceso 2') 
		plt.ylabel('Amplitud [a.u]')
		plt.xlabel('Muestra')
		plt.title('Medición de Temperatura')
		plt.grid()
		plt.legend(loc='upper right')

		# plot 4
		ax_4 = fig.add_subplot(212)
		line4, = ax_4.plot(x_vec,y4_data,'c--',alpha=0.8,label='Proceso 1')  

		plt.ylabel('Amplitud [a.u]')
		plt.xlabel('Muestra')
		plt.title('Filtro de Media Móvil')
		plt.grid()
		plt.legend(loc='upper right')

		plt.show()
    
    # Se actualiza y_data
	line1.set_ydata(y1_data)
	line2.set_ydata(y2_data)
	line3.set_ydata(y3_data)
	line4.set_ydata(y4_data)

    # Ajuste de limites
	if np.min(y1_data)<=line1.axes.get_ylim()[0] or np.max(y1_data)>=line1.axes.get_ylim()[1]:
		# plt.ylim([np.min(y1_data)-np.std(y1_data),np.max(y1_data)+np.std(y1_data)])
		ax_1.set_ylim([np.min(y1_data)-np.std(y1_data),np.max(y1_data)+np.std(y1_data)])
		
	if np.min(y2_data)<=line2.axes.get_ylim()[0] or np.max(y2_data)>=line2.axes.get_ylim()[1]:
		ax_2.set_ylim([np.min(y2_data)-np.std(y2_data),np.max(y2_data)+np.std(y2_data)])

	if np.min(y3_data)<=line3.axes.get_ylim()[0] or np.max(y3_data)>=line3.axes.get_ylim()[1]:
		ax_3.set_ylim([np.min(y3_data)-np.std(y3_data),np.max(y3_data)+np.std(y3_data)])

	if np.min(y4_data)<=line4.axes.get_ylim()[0] or np.max(y4_data)>=line4.axes.get_ylim()[1]:
		ax_4.set_ylim([np.min(y4_data)-np.std(y4_data),np.max(y4_data)+np.std(y4_data)])

	plt.pause(pause_time)
    
    # Vuelven los objetos para poder actualizarlos después
	return line1,line2,line3,line4

try: 
	parser= argparse.ArgumentParser()
	parser.add_argument("server_ip",help="Define server IP")
	parser.add_argument("server_port",help="Define server Port connection")
	args = parser.parse_args()

	print('·-----------------------------------------------------------------------·')
	print('|                                                                       |')
	print('|                            TD3 - Client                               |')
	print('|                     Autor T.P.: Alumno Apellido                       |')
	print('|                             UTN - FRBA                                |')
	print('|                             2ºC - 2021                                |')
	print('|                                                                       |')
	print('·-----------------------------------------------------------------------·')

	# Creating socket
	client_socket_tcp = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	client_socket_tcp.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)	
	client_socket_tcp.connect((args.server_ip,int(args.server_port)))
	
	print('[ Cliente ]-$ Esperando al servidor')
	data = client_socket_tcp.recv(TAM_MAX_DAT).decode()
	
	if data != 'OK':
		print('[ Cliente ]-$ El servidor no está disponible')
		client_socket_tcp.close()
	else:
		
		print('[ Cliente ]-$ El servidor se encuentra disponible')
		input('[ Cliente ]-$ Presionar \"enter\" para establecer la conexión UDP para transmitir los datos ...')
		client_socket_tcp.send(b'AKN')
		print('[ Cliente ]-$ Estableciendo conexión UDP ...')
		#client_socket.sendall(b'Hello, world')
		data = client_socket_tcp.recv(TAM_MAX_DAT).decode()
	

		if data != 'OK':
			print('[ Cliente ]-$ Hubo algún error al establecer la comunicación UDP')
			client_socket_tcp.close()
		else:
			
			time.sleep(2)

			client_socket_udp = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
			client_socket_udp.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)
			client_socket_udp.connect((args.server_ip,int(PUERTO_UDP_1)))
			client_socket_udp.sendto('OK'.encode(),(args.server_ip,int(PUERTO_UDP_1)))
			# client_socket_udp.sendto(b'OK',("192.168.178.43",int(args.server_port)))

			print('[ Cliente ]-$ Conexión UDP establecida con el servidor')
			print('[ Cliente ]-$ Comenzando recepción de datos:')
			print('[ Cliente ]-$ Dato\t| Bytes:')

			# real_time_plot(client_socket_udp)

			size = 300
			x_vec = np.linspace(0,1,size+1)[0:-1]
			# y_vec = np.random.randn(len(x_vec))
			y1_vec = np.zeros(len(x_vec))
			y2_vec = np.zeros(len(x_vec))
			y3_vec = np.zeros(len(x_vec))
			y4_vec = np.zeros(len(x_vec))
			line1 = []
			line2 = []
			line3 = []
			line4 = []
			while (plot_close_event == 0):
				
				# Aca va la comunicacion con el servidor, porque se llama a este metodo y no se sale hasta el final
				data_sensor, address_server = client_socket_udp.recvfrom(TAM_MAX_DAT)				
				print('[ Cliente ]-$ Recibiendo: %s\t| %d (Proc.: %d)' %(data_sensor.decode(),len(data_sensor.decode())+1, time_interleave_aux))
				
				# Específico de la aplicacion servidor que uso de ejemplo. Hay 2 procesos, y cada uno manda cosas al cliente. Entonces, 
				# hago un "interleave" temporal para agarrar cada uno de esos samples.
				if time_interleave_aux == 0:
					y1_vec[-1] = float(data_sensor.decode())
					time_interleave_aux = 1
				else:
					y2_vec[-1] = float(data_sensor.decode())
					time_interleave_aux = 0

					line1,line2,line3,line4 = real_time_plot(x_vec,y1_vec,y2_vec,y3_vec,y4_vec,line1,line2,line3,line4,0.01)
					y1_vec = np.append(y1_vec[1:],0.0)
					y2_vec = np.append(y2_vec[1:],0.0)
					y3_vec = np.append(y1_vec[1:],0.0)
					y4_vec = np.append(y2_vec[1:],0.0)


except OSError as e:
	client_socket_tcp.close()
	client_socket_udp.close()
	print('[ Cliente ] - Error en cliente: %s.' %(sys.stderr))
except KeyboardInterrupt:
	client_socket_tcp.close()
	client_socket_udp.close()
	print('[ Cliente ] - Ctrl-C hitted - Aplicación cliente finalizada')
finally:
	if client_socket_tcp != 0:
		client_socket_tcp.close()
		client_socket_udp.close()
	# if(thread_index > 0):
	# 	for t in threads:
	# 		t.join()
		print('[ Cliente ] - Aplicación cliente finalizada')	
