module Migrations
  class CreateHistoriesTable
    def up
      %q{
          CREATE TABLE public.column_durations (
              column_name varchar(75),
              entry_history_id integer,
              exit_history_id integer,
              entry_at timestamp without time zone,
              exit_at timestamp without time zone
          );
          CREATE INDEX column_name_idx ON public.column_durations USING BTREE (column_name);
          CREATE UNIQUE INDEX entry_history_id_idx ON public.column_durations USING BTREE (entry_history_id);
      }
    end

    def down
      %q{ 
          DROP INDEX column_name_idx;
          DROP INDEX entry_history_id_idx;
          DROP TABLE public.column_durations;
        } 
    end
  end
end