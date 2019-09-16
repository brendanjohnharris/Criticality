classdef LineReWriter < handle
    properties 
        LastBytes = 0;
    end
    methods
        function obj = ReWriteLine(obj, message)
            if obj.LastBytes > 0
                fprintf(repmat('\b', 1, obj.LastBytes))
            end
            Bytes = fprintf(message);
            obj.LastBytes = Bytes;
        end
        function obj = WriteLine(obj, message)
            Bytes = fprintf(message);
            obj.LastBytes = Bytes;
        end
    end
end