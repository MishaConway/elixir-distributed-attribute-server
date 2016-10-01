defmodule DistributedAttributeServer.Slave do
  defmacro __using__(_opts) do
    quote do
      alias DistributedAttributeServer.States.MasterState, as: MasterState
      alias DistributedAttributeServer.States.SlaveState, as: SlaveState

      def init_slave do
        unless master? do
          unless SlaveState.marked?(__MODULE__) do
            MasterState.remove_component __MODULE__
            SlaveState.mark_component __MODULE__
            log "SELF: becoming slave"
            {:ok, pid} = :gen_server.start_link(__MODULE__, %{}, [])
            unless registered_locally? do
              Process.register pid, __MODULE__
            end
            receive_pid = spawn fn -> slave_listen end
            send master_receive_pid, {receive_pid, :subscribe}
            {:ok, pid}
          end
        end
      end

      def slave_listen do
        unless master? do
          receive do
            {:set, attr, value} ->
              log "SLAVE LISTENER: got `set` #{:i.i attr}=#{:i.i value} from master broadcast"
              set_local(attr, value)
            {:set_all, attributes} ->
              log "SLAVE LISTENER: got `set_all` #{:i.i attributes} from master broadcast"
              set_all_local attributes
            {:clear} ->
              log "SLAVE LISTENER: got `clear` from master broadcast"
              clear_local
            _ ->
              IO.puts :stderr, "Unexpected message received"
          end
          slave_listen
        end
      end
    end
  end
end
