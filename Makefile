.PHONY: test benchmark-mojo install-py-packages

install-py-packages:
	conda env create -p venv --file environment.yml

test:
	pytest -W error

benchmark-mojo:
	mojo mojo_impl/naive.mojo 100
	mojo mojo_impl/naive.mojo 1000
	mojo mojo_impl/naive.mojo 10000
	mojo mojo_impl/naive.mojo 100000
	mojo mojo_impl/naive.mojo 1000000

# segfault :(
# mojo mojo_impl/naive.mojo 10000000

	mojo mojo_impl/optimized_a.mojo 100
	mojo mojo_impl/optimized_a.mojo 1000
	mojo mojo_impl/optimized_a.mojo 10000
	mojo mojo_impl/optimized_a.mojo 100000
	mojo mojo_impl/optimized_a.mojo 1000000

# segfault :(
# mojo mojo_impl/optimized_a.mojo 10000000

	mojo mojo_impl/optimized_b.mojo 100
	mojo mojo_impl/optimized_b.mojo 1000
	mojo mojo_impl/optimized_b.mojo 10000
	mojo mojo_impl/optimized_b.mojo 100000
	mojo mojo_impl/optimized_b.mojo 1000000

# segfault :(
#	mojo mojo_impl/optimized_b.mojo 10000000
