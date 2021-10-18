#!/usr/bin/env python3
# -*- coding: utf-8 -*-



# H(f) = (1/M) * sin(pi*f*M)/sen(pi*M)

# H(z) = (1/M) * SUM_(k=0)_(M-1) { z^k }



import os
from matplotlib import scale
import matplotlib.pyplot as plt
from scipy import signal
import numpy as np

dummy_os = os.system("clear")
WORN_N = 4096


M = 11
scale_factor = 1/M
# b = np.ones(M)*scale_factor
# a = np.ones(1)

b = np.ones(M)
a = np.array([M] + [0]*(M-1))

# print(a)
# print(b)

[w, h] = signal.freqz(b,a,worN=WORN_N)

f = w/(2*np.pi)
# ang = np.unwrap(np.angle(h))
ang = np.angle(h)


fig1 = plt.figure(1,figsize=(32,16))
plt.subplot(211)
# plt.plot(f, 20*np.log10(abs(h)))
plt.plot(f, abs(h))
plt.grid()
plt.xlabel('Frecuencia')
plt.ylabel('Magnitud')

plt.subplot(212)
plt.plot(f,ang*180/np.pi)
plt.grid()
plt.xlabel('Frecuencia')
plt.ylabel('Fase [º]')

# [t_i, y_t_i] = signal.dimpulse((b,a,1/100),n=2*M)
# [t_s, y_t_s] = signal.dstep((b,a,1/100),n=2*M)

# fig2 = plt.figure(2,figsize=(32,16))
# plt.plot(t_i,y_t_i[0])
# plt.grid()
# plt.xlabel('Tiempo')
# plt.ylabel('Amplitud [a.u.]')

# fig3 = plt.figure(3,figsize=(32,16))
# plt.plot(t_s,y_t_s[0])
# plt.grid()
# plt.xlabel('Tiempo')
# plt.ylabel('Amplitud [a.u.]')

plt.show()


##--------------------------------------------------

M_vec = np.array([3,11,20,50])

h_vec = np.zeros((len(M_vec),WORN_N),dtype=complex)
ang_vec = np.zeros((len(M_vec),WORN_N))

i = 0

for m in M_vec:

    b = np.ones(m)
    a = np.array([m] + [0]*(m-1))

    # print(a)
    # print(b)

    [w, h_vec[i,:]] = signal.freqz(b,a,worN=WORN_N)

    f = w/(2*np.pi)
    # ang = np.unwrap(np.angle(h))
    ang_vec[i,:] = np.angle(h_vec[i,:])

    i = i + 1


fig1 = plt.figure(1,figsize=(32,16))
plt.subplot(211)
for i in range(0,4):
    plt.plot(f, abs(h_vec[i]),label='M = ' + str(M_vec[i]))
    # plt.plot(f, 20*np.log10(abs(h_vec[i])))

plt.grid()
plt.xlabel('Frecuencia')
plt.ylabel('Magnitud')
plt.legend()

plt.subplot(212)
for i in range(0,4):
    plt.plot(f,ang_vec[i]*180/np.pi,label='M = ' + str(M_vec[i]))
plt.grid()
plt.xlabel('Frecuencia')
plt.ylabel('Fase [º]')
plt.legend()

plt.show()


##--------------------------------------------------

M = 3
b = np.ones(M)
a = np.array([M] + [0]*(M-1))

fft_samples = 1e5
Fs = 1e6
N = int(1e5) # 2^28
t = np.linspace(0,N/Fs,N)
f = 10e3

mva_filter = signal.dlti(b,a,dt=1/Fs)
[t_i, y_t_i] = signal.dimpulse((b,a,1/Fs),n=2*M)

noise = np.random.normal(0, .1, N)
x_t = np.cos(2*np.pi*t*f) + noise
x_t_out = signal.lfilter(b,a,x_t)

x_t_out_dec = np.convolve(x_t_out, y_t_i[0][:,0], mode='valid')[::M]

fig1 = plt.figure(1,figsize=(32,16))
plt.subplot(211)
plt.plot(t,x_t)
plt.grid()
plt.ylabel('Amplitud [a.u.]')

plt.subplot(212)
plt.plot(x_t_out)
plt.plot(x_t_out_dec)
plt.grid()
plt.ylabel('Amplitud [a.u.]')

print(len(x_t))
print(len(x_t_out_dec))

f_in, x_t_fft = signal.periodogram(x_t, Fs, 'flattop', nfft=(2*fft_samples - 1), scaling='spectrum', return_onesided=True)
f_in, x_t_out_fft = signal.periodogram(x_t_out, Fs, 'flattop', nfft=(2*fft_samples - 1), scaling='spectrum', return_onesided=True)
f_dec, x_t_out_dec_fft = signal.periodogram(x_t_out_dec, Fs/M, 'flattop', nfft=(2*fft_samples - 1), scaling='spectrum', return_onesided=True)

fig2 = plt.figure(2,figsize=(32,16))
plt.subplot(211)
plt.plot(f_in/1e3,x_t_fft,label='x_t')
plt.plot(f_in/1e3,x_t_out_fft,label='x_t_out')
plt.grid()
plt.ylabel('Amplitud [dB]')
plt.xlabel('Frequency [kHz]')
plt.legend()

plt.subplot(212)
plt.plot(f_dec/1e3,x_t_out_dec_fft,label='x_t_out_dec')
plt.grid()
plt.ylabel('Amplitud [dB]')
plt.xlabel('Frequency [kHz]')
plt.legend()

plt.show()