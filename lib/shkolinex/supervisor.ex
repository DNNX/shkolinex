defmodule Shkolinex.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    poolboy_config = [
      {:name, {:local, :download_pool}},
      {:worker_module, Shkolinex.DownloadWorker},
      {:size, 0},
      {:max_overflow, 8}
    ]

    children = [
      worker(Shkolinex.Collector, [[]]),
      worker(Shkolinex.Distributor, [[]]),
      :poolboy.child_spec(:download_pool, poolboy_config, []),
      supervisor(Task.Supervisor, [[name: Shkolinex.DownloadSupervisor, restart: :temporary]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
