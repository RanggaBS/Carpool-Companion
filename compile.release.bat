@ECHO OFF

@REM 1

luac -s STimeCycle.lua

IF EXIST luac.out (
	RENAME luac.out STimeCycle.lur
)

@REM 2

luac -s SLvesEff.lua

IF EXIST luac.out (
	RENAME luac.out SLvesEff.lur
)

@REM Move

MOVE /Y STimeCycle.lur ._DEV/release/
MOVE /Y SLvesEff.lur ._DEV/release/

@REM Packs

img -open ._DEV/release/aeimg/stc/Scripts.img -add ._DEV/release/STimeCycle.lur -rebuild
img -open ._DEV/release/aeimg/nonstc/Scripts.img -add ._DEV/release/SLvesEff.lur -rebuild

img -open ._DEV/release/seimg/stc/Scripts.img -add ._DEV/release/STimeCycle.lur -rebuild
img -open ._DEV/release/seimg/nonstc/Scripts.img -add ._DEV/release/SLvesEff.lur -rebuild


