defmodule DistributedAttributeServer do
  defmacro __using__(_opts) do
    quote do
      use DistributedAttributeServer.Master
      use DistributedAttributeServer.Slave
      use DistributedAttributeServer.LocalAttributeServer

      alias DistributedAttributeServer.States.MasterState, as: MasterState
      alias DistributedAttributeServer.States.SlaveState, as: SlaveState

      def start_link _, _ do
        start_link
      end

      def start_link do
        unless master_assigned? do
          master_lock_key = ((__MODULE__ |> to_string) <> ".MasterLock")
          if run_for_master master_lock_key do
            init_master
            #:global.del_lock {master_lock_key, self}
          else
            init_slave
          end
        else
          init_slave
        end
      end

      defp ensure_started do
        start_link
      end

      defp registered_locally? do
        Process.whereis __MODULE__
      end

      def get(attr) do
        ensure_started
        if master? do
          get_local attr
        else
          log "SLAVE: asking master for `get` #{:i.i attr}"
          send master_receive_pid, {self, :get, attr}
          receive do
            {:get_response, value} -> value
            _ -> IO.puts :stderr, "Unexpected message received"
          end
        end
      end

      def set(attr, value) do
        ensure_started
        if master? do
          set_local attr, value
          log "MASTER: broadcasting to slaves `set` #{:i.i attr}=#{:i.i value}"
          master_broadcast {:set, attr, value}
        else
          log "SLAVE: sending master `set` #{:i.i attr}=#{:i.i value}"
          send master_receive_pid, {self, :set, attr, value}
        end
      end

      def set_all(attributes) do
        ensure_started
        if master? do
          set_all_local attributes
          log "MASTER: broadcasting to slaves `set_all` #{:i.i attributes}"
          master_broadcast {:set_all, attributes}
        else
          log "SLAVE: sending master `set_all`  #{:i.i attributes}"
          send master_receive_pid, {self, :set_all, attributes}
        end
      end

      def all do
        ensure_started
        if master? do
          all_local
        else
          log "SLAVE: asking master for `all`"
          send master_receive_pid, {self, :all}
          receive do
            {:all_response, value} -> value
            _ -> IO.puts :stderr, "Unexpected message received"
          end
        end
      end

      def clear do
        ensure_started
        if master? do
          clear_local
          log "MASTER: broadcasting to slaves `clear`"
          master_broadcast {:clear}
        else
          send master_receive_pid, {self, :clear}
        end
      end

      def size do
        ensure_started
        if master? do
          size_local
        else
          send master_receive_pid, {self, :size}
          receive do
            {:size_response, value} -> value
            _ -> IO.puts :stderr, "Unexpected message received"
          end
        end
      end

      defp log str do
        IO.puts str
      end
    end
  end
end
