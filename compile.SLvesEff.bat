@ECHO OFF

luac -s SLvesEff.lua

IF EXIST MOD_1.lur (
	DEL MOD_1.lur
)

IF EXIST luac.out (
	RENAME luac.out MOD_1.lur
)

MOVE /Y MOD_1.lur ._DEV/output/
