function [ raw_fragments, last_fragment ] = getfragments( database_collection, startfr, endfr )
    fprintf('Starting getting fragment log data...\n')
    sizeofdb = Mongo().count(database_collection);
    fprintf('Counted %d fragments total.\n', sizeofdb)
    if (sizeofdb - startfr) - endfr < 0 || endfr == 0
        length1 = sizeofdb - startfr;
    else
        length1 = endfr;
    end
    
    % don't preallocate too much
    raw_fragments = cell(length1,5);
    bb = BsonBuffer;
    query = bb.finish();
    cursor = MongoCursor(query);
    cursor.skip = startfr;
    cursor.limit = endfr;
    pos_in_array = 1;
    if Mongo().find(database_collection, cursor)
        fprintf('\nStarted getting fragments as text...\n');
       while cursor.next()
          % do something with cursor.value()
          raw_fragments{pos_in_array,1} = cursor.value();
          pos_in_array = pos_in_array + 1;
          if rem(pos_in_array, 10000) == 0
              fprintf('Got %d fragments...\n', pos_in_array)
          end
       end
    end
    
    fprintf('Converting BSON to text (this might take a while)...\n');
    length2 = length(raw_fragments);
    for i=1:length(raw_fragments)
        transition_state = raw_fragments{i,1};
        raw_fragments{i,1} = datestr(transition_state.datetime('start_ts'));
        raw_fragments{i,3} = transition_state.string('channel_name');
        raw_fragments{i,4} = transition_state.string('show_name');
        raw_fragments{i,5} = transition_state.string('client_uuid');
        if rem(i, 10000) == 0
            fprintf('Converted %d fragments...\n', i);
        end
    end
    
    if endfr == 0
        last_fragment = length2 + startfr;
    else
        last_fragment = min(startfr + endfr, length2 + startfr);
    end        
    fprintf('Finished getting %d fragments.\n', length2);
end

