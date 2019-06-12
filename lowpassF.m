function fSig=lowpassF(sign,fs,fc)

orderN=2;
Wn=fc/(fs/2);
[B,A] = butter(orderN,Wn,'low');

fSig=filtfilt(B,A,sign);

end    
