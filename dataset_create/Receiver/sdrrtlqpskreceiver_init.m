function SimParams = sdruqpskreceiver_init(symbolRate,....
    centerFreq,gain,captureTime,isHDLCompatible)
%% General simulation parameters

%SimParams.ModulationOrder = 2^SimParams.k; % 16 qam alphabet size
%SimParams.Fs              = symbolRate*log2(SimParams.ModulationOrder)/SimParams.n; % Sample rate
SimParams.ModulationOrderheader = 4; % QPSK alphabet size
SimParams.Interpolation   = 62500; % Interpolation factor
SimParams.Decimation      = 1; % Decimation factor
SimParams.Rsym            = symbolRate/SimParams.Interpolation;


SimParams.Tsym            = 1/SimParams.Rsym; % Symbol time in sec


% If HDL compatible, code will not be optimized in performance
if isHDLCompatible
    SimParams.CFCAlgorithm = 'Correlation-Based';
else
    SimParams.CFCAlgorithm = 'FFT-Based';
end

%% Frame Specifications
% SimParams.BarkerCode      = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1]; % Bipolar Barker Code
% SimParams.BarkerLength    = length(SimParams.BarkerCode);
% SimParams.HeaderLength    = SimParams.BarkerLength * 2;                   % Duplicate 2 Barker codes to be as a header
% SimParams.MessageLength   = log2(SimParams.ModulationOrder);               
% SimParams.NumberOfMessage = 5592/SimParams.n;                                          % Number of messages in a frame
% SimParams.seqNumLen       = 12;
% SimParams.flaglen       = 4;
% SimParams.PayloadLength   = SimParams.NumberOfMessage * SimParams.MessageLength;
% SimParams.FrameSize       = ((SimParams.HeaderLength+ SimParams.seqNumLen+SimParams.flaglen)/log2(SimParams.ModulationOrderheader) + SimParams.PayloadLength/ log2(SimParams.ModulationOrder)*SimParams.n); %frame size in symbols                             % Frame size in symbols
% SimParams.FrameTime       = SimParams.Tsym*SimParams.FrameSize;

%% Rx parameters
SimParams.RolloffFactor     = 0.5;                      % Rolloff Factor of Raised Cosine Filter
SimParams.ScramblerBase     = 2;
SimParams.ScramblerPolynomial           = [1 1 1 0 1];
SimParams.ScramblerInitialConditions    = zeros(1, 4);
SimParams.RaisedCosineFilterSpan = 10;                  % Filter span of Raised Cosine Tx Rx filters (in symbols)
SimParams.DesiredPower                  = 2;            % AGC desired output power (in watts)
SimParams.AveragingLength               = 50;           % AGC averaging length
SimParams.MaxPowerGain                  = 60;           % AGC maximum output power gain
SimParams.MaximumFrequencyOffset        = 6e3;
% Look into model for details for details of PLL parameter choice. 
% Refer equation 7.30 of "Digital Communications - A Discrete-Time Approach" by Michael Rice.
K = 1;
A = 1/sqrt(2);
SimParams.PhaseRecoveryLoopBandwidth    = 0.01;         % Normalized loop bandwidth for fine frequency compensation
SimParams.PhaseRecoveryDampingFactor    = 1;            % Damping Factor for fine frequency compensation
SimParams.TimingRecoveryLoopBandwidth   = 0.01;         % Normalized loop bandwidth for timing recovery
SimParams.TimingRecoveryDampingFactor   = 1;            % Damping Factor for timing recovery
% K_p for Timing Recovery PLL, determined by 2KA^2*2.7 (for binary PAM),
% QPSK could be treated as two individual binary PAM,
% 2.7 is for raised cosine filter with roll-off factor 0.5
SimParams.TimingErrorDetectorGain       = 2.7*2*K*A^2+2.7*2*K*A^2;
SimParams.PreambleDetectorThreshold     = 1;
SimParams.PreambleDetectorThreshold2     = 80;

%% RTL receiver parameters

SimParams.RTLCenterFrequency           = centerFreq;
SimParams.RTLGain                      = gain;
SimParams.RTLFrontEndSampleRate        = 250000;%SimParams.Rsym * 2; % Nyquist sampling theorem
SimParams.RTLFrameLength               = 4;

% Experiment parameters
SimParams.RTLFrameTime                 = SimParams.RTLFrameLength/SimParams.RTLFrontEndSampleRate;
SimParams.StopTime                      = captureTime;