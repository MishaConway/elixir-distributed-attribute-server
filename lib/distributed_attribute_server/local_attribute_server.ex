defmodule DistributedAttributeServer.LocalAttributeServer do
  defmacro __using__(_opts) do
    quote do
      use GenServer

      def get_local(attr) do
        :gen_server.call(__MODULE__, {:get, attr})
      end

      def set_local(attr, value) do
        :gen_server.cast(__MODULE__, {:set, attr, value})
      end

      def set_all_local(attributes) do
        ensure_started
        #todo: verify attributes is map or keyword list
        #todo: if keyword list, cast to map
        :gen_server.cast(__MODULE__, {:set_all, attributes})
      end

      def all_local do
        :gen_server.call(__MODULE__, {:all})
      end

      def clear_local do
        :gen_server.cast(__MODULE__, {:clear})
      end

      def size_local do
        :gen_server.call(__MODULE__, {:size})
      end

      def handle_call({:get, attr}, _from, attributes) do
        {:reply, attributes[attr], attributes}
      end

      def handle_call({:all}, _from, attributes) do
        {:reply, attributes, attributes}
      end

      def handle_call({:size}, _from, attributes) do
        {:reply, Enum.count(attributes), attributes}
      end

      def handle_cast({:set, attr, value}, attributes) do
        {:noreply, Map.put(attributes, attr, value)}
      end

      def handle_cast({:set_all, new_attributes}, attributes) do
        {:noreply, new_attributes}
      end

      def handle_cast({:clear}, attributes) do
        {:noreply, %{}}
      end
    end
  end
end
