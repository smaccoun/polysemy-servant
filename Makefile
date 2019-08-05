dev:
	stack build --fast
run:
	stack exec polysemy-servant
fmt:
	find src -name '*.hs' -print | xargs floskell
	find test -name '*.hs' -print | xargs floskell
