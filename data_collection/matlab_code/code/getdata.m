function [ raw_fragments_bson ] = getusers( database_collection, startfr, endfr )
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
          raw_fragments{pos_in_array, 1} = transition_state.string('client_uuid');
          raw_fragments{pos_in_array, 2} = transition_state.string('facebook_id');
          raw_fragments{pos_in_array, 3} = transition_state.string('anonymous_id');
          if rem(pos_in_array, 10000) == 0
              fprintf('Got %d users...\n', pos_in_array)
          end
       end
    end
end

