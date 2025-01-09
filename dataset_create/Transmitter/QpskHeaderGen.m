function [qpskdataheader,moddata] = QpskHeaderGen(seqnumqpsk)

pTransmitterFilter = comm.RaisedCosineTransmitFilter( ...
                'RolloffFactor',                0.5, ...
                'FilterSpanInSymbols',          10, ...
                'OutputSamplesPerSymbol',       2);




moddata=[];
qpskdataheader=[];
pBarkerCode = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1];
ubc = ((pBarkerCode + 1) / 2)';
temp = (repmat(ubc,1,2))';
pHeader = temp(:);

i=0;
while i<1
    tag1 = de2bi([1;1;1;1]);
    tag10 = de2bi([0;0;0;0]);
    i=i+1;
    data = randi([0 , 3],5592,1);
    bits = de2bi(data, 2, 'left-msb')';
    msgBin = bits(:);
    seqNUmbin = de2bi(seqnumqpsk, 2*6, 'left-msb')';
    if i>7
        msgBin=[seqNUmbin;tag10;msgBin];
    else
        msgBin=[seqNUmbin;tag1;msgBin];
    end
    
    % Append the scrambled bit sequence to the header
    y = [pHeader ; msgBin];
    y=pskmod(y,4,pi/4,InputType="bit",OutputDataType="double");
    moddata=[moddata,y];
    y_=pTransmitterFilter(y);
    qpskdataheader = [qpskdataheader,y_];
    
    
end



end

