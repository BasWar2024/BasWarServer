function unittest.testClusterQueue()
    if not gg.clusterQueue then
        gg.clusterQueue = ggclass.ClusterQueue.new(skynet.config.id,skynet.config.id,skynet.self())
    end
    local lockFunc = function (...)
        skynet.sleep(100)
        print(skynet.timestamp(),...)
        return ...
    end
    for i = 1, 5 do
        skynet.fork(function ()
            print(i,"return",gg.clusterQueue:queue("testClusterQueue1",lockFunc,"lockFunc1",i))
        end)
    end

    for i = 1, 5 do
        skynet.fork(function ()
            print(i,"return",gg.clusterQueue:queue("testClusterQueue2",lockFunc,"lockFunc2",i))
        end)
    end
end
