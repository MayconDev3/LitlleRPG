-- Procedural R6 animation; no external animation permissions required.
local Run=game:GetService("RunService")
local character=script.Parent
local hum=character:WaitForChild("Humanoid")
local torso=character:WaitForChild("Torso")
local joints={torso:WaitForChild("Left Shoulder"),torso:WaitForChild("Right Shoulder"),torso:WaitForChild("Left Hip"),torso:WaitForChild("Right Hip")}
local connection
connection=Run.PreSimulation:Connect(function()
 if not character.Parent or hum.Health<=0 then connection:Disconnect(); return end
 local moving=hum.MoveDirection.Magnitude>.05
 local swing=moving and math.sin(os.clock()*10)*.65 or math.sin(os.clock()*2)*.025
 for i,joint in ipairs(joints) do
  local angle=swing*((i==1 or i==4) and 1 or -1)
  if i==2 and character:FindFirstChildOfClass("Tool") then angle=-.45 end
  joint.Transform=CFrame.Angles(angle,0,0)
 end
end)
