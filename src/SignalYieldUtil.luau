local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.SharedPackages.Signal)
local CleanupUtil = require(ReplicatedStorage.SharedUtils.CleanupUtil)

local SignalYieldUtil = {}

export type SignalYield = {
    HasYielded: Signal.Signal<any>;

    Yield: (self: SignalYield, yieldDuration: number) -> ();
    Reset: (self: SignalYield) -> ();

    Destroy: (self: SignalYield) -> ();
}
type PrivateSignalYield = {
    _yieldBin: {CleanupUtil.Trash};
}

function SignalYieldUtil.new(): SignalYield
    local self = {}:: SignalYield & PrivateSignalYield

    self._yieldBin = {}

    self.HasYielded = Signal.new()

    function self.Yield(self: SignalYield & PrivateSignalYield, yieldDuration: number)
        CleanupUtil.InsertBin(self._yieldBin, task.delay(yieldDuration, function()
            self.HasYielded:Fire()
        end))
    end

    function self.Reset(self: SignalYield & PrivateSignalYield)
        CleanupUtil.Clean(self._yieldBin)
    end
    
    return self
end

return SignalYieldUtil
