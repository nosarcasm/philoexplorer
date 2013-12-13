function [ raw_fragments ] = getunknown( database_collection, startfr, endfr )
    fprintf('Starting getting fragment log data...\n')
    sizeofdb = Mongo().count(database_collection);
    fprintf('Counted %d rows total.\n', sizeofdb)
    raw_fragments = cell(sizeofdb,1);
    bb = BsonBuffer;
    query = bb.finish();
    cursor = MongoCursor(query);
    cursor.skip = startfr;
    cursor.limit = endfr;
    pos_in_array = 0;
    if Mongo().find(database_collection, cursor)
        fprintf('Started getting users...\n');
       while cursor.next()
          pos_in_array = pos_in_array + 1;
          % do something with cursor.value()
          transition_state = cursor.value();
          raw_fragments{pos_in_array, 1} = transition_state;
          if rem(pos_in_array, 10000) == 0
              fprintf('Got %d unknown...\n', pos_in_array)
          end
       end
    end
end

