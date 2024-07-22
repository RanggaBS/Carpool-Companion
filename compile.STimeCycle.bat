@ECHO OFF

luac -s main.DSL.lua

IF EXIST STimeCycle.lur (
	DEL STimeCycle.lur
)

IF EXIST luac.out (
	RENAME luac.out MOD_1.lur
)

MOVE /Y MOD_1.lur ._DEV/output

@REM Rebuild archive
@REM img -open "Scripts.img" -add "STimeCycle.lur" -rebuild
