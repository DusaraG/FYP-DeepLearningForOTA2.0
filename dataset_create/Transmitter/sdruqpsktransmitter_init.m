function SimParams = sdruqpsktransmitter_init(platform,address,symbolRate,....
    centerFreq,gain,captureTime,k,n)
%   Copyright 2012-2023 The MathWorks, Inc.

%% General simulation parameters
SimParams.k =k;
SimParams.n =n/2;%channel uses
SimParams.ModulationOrder = 2^SimParams.k;
SimParams.ModulationOrderheader = 4; % QPSK alphabet size
SimParams.Interpolation   = 2; % Interpolation factor
SimParams.Decimation      = 1; % Decimation factor
SimParams.Fs              = symbolRate*log2(SimParams.ModulationOrder)/SimParams.n;
% SimParams.Rsym            = sampleRate/SimParams.Interpolation; % Symbol rate in Hertz
SimParams.Rsym            = symbolRate;

SimParams.Tsym            = 1/SimParams.Rsym; % Symbol time in sec

%% Frame Specifications
SimParams.BarkerCode      = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1];     % Bipolar Barker Code
SimParams.BarkerLength    = length(SimParams.BarkerCode);
SimParams.HeaderLength    = SimParams.BarkerLength * 2;                   % Duplicate 2 Barker codes to be as a header

SimParams.MessageLength   = log2(SimParams.ModulationOrder);               
SimParams.NumberOfMessage = 5592/SimParams.n;                                          % Number of messages in a frame
SimParams.seqNumLen       = 12;
SimParams.flaglen         = 4;
SimParams.PayloadLength   = SimParams.NumberOfMessage * SimParams.MessageLength; 
SimParams.FrameSize       = ((SimParams.HeaderLength+ SimParams.seqNumLen+SimParams.flaglen )/log2(SimParams.ModulationOrderheader) + SimParams.PayloadLength/ log2(SimParams.ModulationOrder)*SimParams.n);
                                        % Frame size in symbols
SimParams.FrameTime       = SimParams.Tsym*SimParams.FrameSize;

%% Tx parameters
SimParams.RolloffFactor     = 0.5;                                        % Rolloff Factor of Raised Cosine Filter
SimParams.ScramblerBase     = 2;
SimParams.ScramblerPolynomial           = [1 1 1 0 1];
SimParams.ScramblerInitialConditions    = [0 0 0 0];
SimParams.RaisedCosineFilterSpan = 10; % Filter span of Raised Cosine Tx Rx filters (in symbols)

%% USRP transmitter parameters
SimParams.Platform                      = platform;
SimParams.Address                       = address;
SimParams.MasterClockRate = 100e6;          % Hz
  

SimParams.USRPCenterFrequency       = centerFreq;
SimParams.USRPGain                  = gain;
SimParams.USRPFrontEndSampleRate    = SimParams.Rsym * 2; % Nyquist sampling theorem
SimParams.USRPInterpolationFactor   = SimParams.MasterClockRate/SimParams.USRPFrontEndSampleRate;
SimParams.USRPFrameLength           = SimParams.Interpolation * SimParams.FrameSize;

% Experiment Parameters
SimParams.USRPFrameTime = SimParams.USRPFrameLength/SimParams.USRPFrontEndSampleRate;
SimParams.StopTime = captureTime;

