
current_dir = $(shell pwd)
update-CHANGELOG:
ifdef next-rel
	@echo "next-rel is $(next-rel)"
	@docker run -v $(current_dir):/workdir quay.io/git-chglog/git-chglog -o CHANGELOG.md --next-release $(next-rel)
else
	@echo "no next-rel defined"
	@docker run -v $(current_dir):/workdir quay.io/git-chglog/git-chglog -o CHANGELOG.md --next-release unreleased
endif
