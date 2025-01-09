function overflow = runSDRuQPSKReceiver(prmQPSKReceiver,~)
persistent radio
if isempty(radio)

    radio = comm.SDRRTLReceiver('0','CenterFrequency',prmQPSKReceiver.RTLCenterFrequency,'SampleRate',prmQPSKReceiver.RTLFrontEndSampleRate, ...
    'SamplesPerFrame',4,'EnableTunerAGC',true,'OutputDataType','double');
    display(radio)
    
end


cleanupRadio = onCleanup(@()release(radio));

% Initialize variables
currentTime = zeros(1, 1);
overflow = uint32(0);
rxsignal=zeros(2000,4, 'like', complex(0));

disp("started receiving")

[rcvdSignal_, ~] = step(radio);
THRE = 0.09;
while any(abs(rcvdSignal_) < THRE)
    [rcvdSignal_, ~] = step(radio);

end
for i =1:2000

[rcvdSignal_, ~, toverflow] = step(radio);


rxsignal(i,:) = rcvdSignal_;



overflow = toverflow + overflow;

end

save("rx","rxsignal");
disp("finished receiving")



