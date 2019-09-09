function [TS_DataMat, operations, mus, etas]  = extractDataMat(data, yourmus, youretas, yourops)
%EXTRACTDATAMAT Extract a datamat at a specific mu/eta/ops from
%time_series_data. mus and etas label the rows of the TS_DataMat,
%operations labels the columns (with operation IDS). 

if ~checkConsistency(data)
    error('The data struct must be consisted; same cp and operations for every row')
end

if nargin < 2 || isempty(yourmus)
    yourmus = data(1).Inputs.cp_range;
end
if nargin < 3 || isempty(youretas)
    youretas = arrayfun(@(x) data(1).Inputs.eta, data);
end
if nargin < 4 || isempty(yourops)
    yourops = data(1).Operations.ID;
end

%% Go through and get the etas first; this is the surface dimension of the data struct
data  = data(ismembertol(youretas, arrayfun(@(x) x.Inputs.eta, data)), :); % Rows of data struct correspond to one eta

%% Then concatenate all the datamats
TS_DataMat = arrayfun(@(x) x.TS_DataMat, data, 'un', 0);
mus = arrayfun(@(x) x.Inputs.cp_range, data, 'un', 0);
operations = arrayfun(@(x) x.Operations.ID, data, 'un', 0);
TS_DataMat = vertcat(TS_DataMat{:});
mus = horzcat(mus{:})'; % Column vector
operations = data(1).Operations.ID'; % Row vector
etas = repmat(arrayfun(@(x) x.Inputs.eta, data), 1, size(data(1).TS_DataMat, 1))';
etas = etas(:); % Column as well

%% And select the relevant rows and columns
muidxs = ismembertol(mus, yourmus);
opidxs = ismembertol(operations, yourops);
TS_DataMat = TS_DataMat(muidxs, opidxs);
mus = mus(muidxs);
operations = operations(opidxs);
etas = etas(muidxs);
end

