classdef reWriter < handle
    properties 
        LastBytes = 0;
        Active = 1;
        thatWasMe = 0;
        ID = [];
    end
    methods (Static)
        function out = setgetWhichOne(x)
            % So, this is a vector
            % The first element is the currently active reWriter
            % The subsequent elements refer to created reWriters (whether
            % thay have been deleted or not), with a unique index
            % defined as the ID property of each instance.
            persistent whichOne;
            if nargin
                whichOne = x;
            end
            out = whichOne;
        end
    end
    methods
        function obj = reWriter()
            if isempty(reWriter.setgetWhichOne)
                obj.ID = 1;
                reWriter.setgetWhichOne([0, 1]); % You are the only instance, but you are not yet activated
            else
                obj.ID = max(reWriter.setgetWhichOne) + 1; % You can have the next availiable ID
                reWriter.setgetWhichOne([reWriter.setgetWhichOne, obj.ID]);
            end   
        end
        function obj = reWrite(obj, message, varargin)
            whichOne = reWriter.setgetWhichOne;
            if obj.LastBytes > 0 && obj.Active && (obj.ID == whichOne(1))
                fprintf(repmat('\b', 1, obj.LastBytes));
            end
            obj = Write(obj, message, varargin{:});
        end
        function obj = Write(obj, message, varargin)
            Bytes = builtin('fprintf', message, varargin{:});
            obj.LastBytes = Bytes;
            whichOne = reWriter.setgetWhichOne;
            whichOne(1) = obj.ID; % Pick me
            reWriter.setgetWhichOne(whichOne);
        end
        function obj = inactivate(obj)
            obj.Active = 0;
        end
    end
end
