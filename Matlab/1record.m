function [ record ] = record(sampleRate, recordTime)
%Aufnahme �ber Mikrofon
recorder = audiorecorder(sampleRate,16,1,1); 
disp('Start speaking.');
disp(num2str(recordTime));
recordblocking(recorder, recordTime);
disp('End of Recording.');

record = getaudiodata(recorder);
end
