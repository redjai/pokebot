module Migrations
  class CreateHistoriesTable
    def up
      %q{
          CREATE TABLE public.column_durations (
              task varchar(75),
              board_id integer,
              workflow integer,
              column_name varchar(75),
              entry_details text,
              entry_history_id integer,
              entry_history_event varchar(50),
              entry_event_type varchar(50),
              exit_details text,
              exit_history_id integer,
              exit_history_event varchar(50),
              exit_event_type varchar(50),
              entry_at timestamp without time zone,
              exit_at timestamp without time zone,
              duration integer
          );
          CREATE INDEX column_name_task_idx ON public.column_durations USING BTREE (task, column_name);
          CREATE UNIQUE INDEX entry_history_id_idx ON public.column_durations USING BTREE (entry_history_id);
      }
    end

    def down
      %q{ 
          DROP INDEX column_name_task_idx;
          DROP INDEX entry_history_id_idx;
          DROP TABLE public.column_durations;
        } 
    end
  end
end