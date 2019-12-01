<script>
	let searchQuery = "";
	let searchResults = [{title: "a", url: "https://example.com"}];

	function handleSearch(event) {
		searchQuery = event ? event.target.value : "";
		fetch(`/search/${searchQuery}`)
			.then(response => response.json())
			.then(data => {
				searchResults = data;
			})
	}

	handleSearch();
</script>

<main>
	<h1>Psoogle</h1>
	<input id="search" on:input={handleSearch} autocomplete="off">
	<ul>
		{#each searchResults as result}
			<a href={result.url}><li>{result.title}</li></a>
		{/each}
	</ul>
</main>
<style>
	main {
		text-align: center;
		padding: 1em;
		max-width: 240px;
		margin: 0 auto;
	}

	h1 {
		background: linear-gradient(to right, #ff8a00 0%, #da1b60 100%);
		background-clip: text;
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		text-transform: uppercase;
		font-size: 4em;
		font-weight: 100;
		font-family: 'Anton', sans-serif;
	}

	input {
		width: 400px;
	}

	ul {
		list-style: none;
		padding: 0;
	}

	a {
		color: black;
	}

	li {
		width: 300px;
		box-shadow: 2px 2px 3px 3px rgba(128, 128, 128, .5);
		margin: 15px auto 10px auto;
		padding: 15px;
		border-radius: 10px;
		font-weight: bold;
		font-family: 'Montserrat', sans-serif;
	}

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}
</style>