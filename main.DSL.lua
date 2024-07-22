---@diagnostic disable: duplicate-set-field
-- STimeCycle.lua

-- -------------------------------------------------------------------------- --
--                           Shared Global Variable                           --
-- -------------------------------------------------------------------------- --

---@class CarpoolCompanion
shared.CARPOOL_COMPANION = {
	CONSTANT = {},
	VAR = {},
	FUNC = {},
	UTIL = {},
}

-- -------------------------------------------------------------------------- --
--                                  Constant                                  --
-- -------------------------------------------------------------------------- --

shared.CARPOOL_COMPANION.CONSTANT.ACTION_NODE = {
	MOVE_TO = "/Global/Vehicles/Cars/MoveToVehicle/MoveToVehicleRHS/MoveTo",
	GET_IN = "/Global/Vehicles/Cars/MoveToVehicle/AtCar/GetInVehicle/RightHandSide/Sedan",
	GET_OFF = "/Global/Vehicles/Cars/CarGround/Dismount/GetOff",
}

-- -------------------------------------------------------------------------- --
--                               Configurations                               --
-- -------------------------------------------------------------------------- --

-- 0: Left front seat (driver seat)
-- 1: Right front seat (front seat)
-- 2: Right rear seat
-- 3: Left rear seat
shared.CARPOOL_COMPANION.VAR.SEAT = 1

-- In miliseconds
shared.CARPOOL_COMPANION.VAR.FORCE_EXIT_WAIT_TIME = 3000

-- -------------------------------------------------------------------------- --
--                                 Main Thread                                --
-- -------------------------------------------------------------------------- --

function _G.T_CARPOOL_COMPANION()
	while not SystemIsReady() or AreaIsLoading() do
		Wait(0)
	end

	-- Localize & shorten
	---@class CarpoolCompanion
	local CC = shared.CARPOOL_COMPANION

	-- Local Variables

	local follower = -1
	local lastDriving = 0

	while true do
		Wait(0)

		if
			PedHasAllyFollower(gPlayer)
			and not PedIsDead(PedGetAllyFollower(gPlayer))
		then
			follower = PedGetAllyFollower(gPlayer)

			if
				PlayerIsInAnyVehicle()
				and CC.UTIL.VehicleIsCar(VehicleFromDriver(gPlayer))
			then
				lastDriving = GetTimer()

				CC.FUNC.HandlePedEnterVehicle(
					follower,
					VehicleFromDriver(gPlayer),
					CC.VAR.SEAT
				)

			-- If player is not in any vehicle
			else
				CC.FUNC.HandlePedExitVehicle(follower)

				-- Force exit vehicle if remains in the car for more than X seconds
				if
					PedIsInAnyVehicle(follower)
					and GetTimer() >= lastDriving + CC.VAR.FORCE_EXIT_WAIT_TIME
				then
					PedWarpOutOfCar(follower)
				end
			end
		end
	end
end

-- -------------------------------------------------------------------------- --
--                                 Entry Point                                --
-- -------------------------------------------------------------------------- --

function main()
	while not SystemIsReady() or AreaIsLoading() do
		Wait(0)
	end

	-- Create & run the thread

	shared.CARPOOL_COMPANION.MAIN_THREAD = CreateThread(T_CARPOOL_COMPANION)

	while true do
		Wait(0)
	end
end

-- -------------------------------------------------------------------------- --
--                              Handler & Utility                             --
-- -------------------------------------------------------------------------- --

---@param ped integer
---@param vehicle integer
---@param seat integer
function shared.CARPOOL_COMPANION.FUNC.HandlePedEnterVehicle(ped, vehicle, seat)
	if not PedIsInVehicle(ped, vehicle) then
		PedEnterVehicle(ped, vehicle)
		PedSetActionNode(
			ped,
			shared.CARPOOL_COMPANION.CONSTANT.ACTION_NODE.MOVE_TO,
			"Act/Vehicles.act"
		)
		while PedMePlaying(ped, "MoveToVehicle") do
			Wait(0)
		end
		if not PedMePlaying(ped, "GetInVehicle") then
			PedSetActionNode(
				ped,
				shared.CARPOOL_COMPANION.CONSTANT.ACTION_NODE.GET_IN,
				"Act/Vehicles.act"
			)
		end
		PedWarpIntoCar(ped, vehicle, seat)
	end
end

---@param ped integer
function shared.CARPOOL_COMPANION.FUNC.HandlePedExitVehicle(ped)
	if PedIsInAnyVehicle(ped) then
		if not PedMePlaying(ped, "Dismount") then
			PedSetActionNode(
				ped,
				shared.CARPOOL_COMPANION.CONSTANT.ACTION_NODE.GET_OFF,
				"Act/Vehicles.act"
			)
		end
		PedExitVehicle(ped)
	end
end

---@param vehicle integer
---@return boolean
function shared.CARPOOL_COMPANION.UTIL.VehicleIsCar(vehicle)
	-- Lookup Table (LUT)
	local CARS_LOOKUP = {
		[286] = true, -- Taxi
		[290] = true, -- Limo
		[291] = true, -- Delivery Truck
		[292] = true, -- Foreign Car
		[293] = true, -- Regular Car
		[294] = true, -- 70 Wagon
		[295] = true, -- Police Car
		[296] = true, -- Domestic Car
		[297] = true, -- SUV
	}
	return CARS_LOOKUP[VehicleGetModelId(vehicle)] or false
end
