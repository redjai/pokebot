module Migrations
    class CreateHistoriesTable
      def up
        %q{
            CREATE TABLE public.columns (
                client_id varchar(50),
                board_id integer,
                workflow integer,
                column_name varchar(75),
                mean float,
                variance float,
                population integer,
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