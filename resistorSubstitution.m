% ***********************************************************************
%  License          : LGPLv3
%
%  Author           : Andreas Kaeberlein
%  eMail            : andreas.kaeberlein@web.de
%
%  File             : resistorSubstitution.m
%  Description      : replaces given resistor value by E-series combination
%  Octave           : 4.0
%
%  Sources          : none
%
%  on               : 2017-03-26
% ************************************************************************



function subsResistors = resistorSubstitution(varargin)
%%
%%  Usage
%%  =====
%%
%%  value:          double          -> resistor value to replace
%%  tolerance:      double          -> residualer relative deviation (tolerance = dR/R)     [ 1% ]
%%  eseries:        string          -> used E series for searching                          [ E24 ]
%%  resistors:      double array    -> collection of resistors or min/max value for eseries [ 1 10e6 ]
%%



% parse input
% SRC: https://www.gnu.org/software/octave/doc/interpreter/Variable_002dlength-Argument-Lists.html
% SRC: https://de.mathworks.com/help/matlab/ref/inputparser.addoptional.html
%
p               = inputParser();            % create object
p.FunctionName  = 'resistorSubstitution';   % set function name

p.addRequired('value', @isnumeric);             % mandatory argument

p.addOptional('tolerance', 0.01, @isnumeric);                                                               % tolerance with 0.01 default
p.addOptional('eseries', 'E24', @(x) any (strcmp (x, {'E3', 'E6', 'E12', 'E24', 'E48', 'E96', 'None'})));   % Info: https://de.wikipedia.org/wiki/E-Reihe
p.addOptional ('resistors', [1 10e6], @isvector);                                                           % Min/max of resistor for E-Series generation, or collection of resistors

p.parse(varargin{:});   % Run created parser on inputs
%


% E96 Series as Lookup-Table
% SRC: http://www.elektronik-kompendium.de/sites/bau/1109071.htm
%
ser.E3  =   [   1.00 2.20 4.70                                              ];

ser.E6  =   [   1.00 1.50 2.20 3.30 4.70 6.80                               ];

ser.E12 =   [   1.00 1.20 1.50 1.80 2.20 2.70 3.30 3.90 4.70 5.60 6.80 8.20 ];

ser.E24 =   [   1.00 1.10 1.20 1.30 1.50 1.60 1.80 2.00 2.20 2.40 2.70 3.00 ...
                3.30 3.60 3.90 4.30 4.70 5.10 5.60 6.20 6.80 7.50 8.20 9.10 ];

ser.E48 =   [   1.00 1.05 1.10 1.15 1.21 1.27 1.33 1.40 1.47 1.54 1.62 1.69 ...
                1.78 1.87 1.96 2.05 2.15 2.26 2.37 2.49 2.61 2.74 2.87 3.01 ...
                3.16 3.32 3.48 3.65 3.83 4.02 4.22 4.42 4.64 4.87 5.11 5.36 ...
                5.62 5.90 6.19 6.49 6.81 7.15 7.50 7.87 8.25 8.66 9.09 9.53 ];

ser.E96 =   [   1.00 1.02 1.05 1.07 1.10 1.13 1.15 1.18 1.21 1.24 1.27 1.30 ...
                1.33 1.37 1.40 1.43 1.47 1.50 1.54 1.58 1.62 1.65 1.69 1.74 ...
                1.78 1.82 1.87 1.91 1.96 2.00 2.05 2.10 2.15 2.21 2.26 2.32 ...
                2.37 2.43 2.49 2.55 2.61 2.67 2.74 2.80 2.87 2.94 3.01 3.09 ...
                3.16 3.24 3.32 3.40 3.48 3.57 3.65 3.74 3.83 3.92 4.02 4.12 ...
                4.22 4.32 4.42 4.53 4.64 4.75 4.87 4.99 5.11 5.23 5.36 5.49 ...
                5.62 5.76 5.90 6.04 6.19 6.34 6.49 6.65 6.81 6.98 7.15 7.32 ...
                7.50 7.68 7.87 8.06 8.25 8.45 8.66 8.87 9.09 9.31 9.53 9.76 ];
%


% build available resistor table
%
if (strcmp('None', p.Results.eseries))
    avlValues   = p.Results.resistors;  % copy values
else
    if (length(p.Results.resistors) > 2)                % check parameters
        error('Use [MinVal MaxVal] in Eseries mode');   % generate user message
    end

    % some preparations
    [s expRmin]     = strread(strrep(sprintf('%E',p.Results.resistors(1)),'E','#'),'%f#%f');    % extract exponents
    [s expRmax]     = strread(strrep(sprintf('%E',p.Results.resistors(2)),'E','#'),'%f#%f');

    % build decade series
    avlValues = [];
    for i=expRmin:1:expRmax
        for j=1:length(ser.(p.Results.eseries))
            avlValues(end+1) = ser.(p.Results.eseries)(j)*10^i;
        end;
    end;
end;
%



avlValues


%p.Results.value
%p.Results.tolerance
%p.Results.eseries
%p.Results.resistors


