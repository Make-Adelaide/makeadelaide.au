
"use strict";

const MAKE_ADELAIDE_ADDRESS = "";

const RPC_PROVIDER = "http://localhost:8545";

const get_articles_hash = (provider) => provider.call({
	"to": MAKE_ADELAIDE_ADDRESS,
	"data": "" // computed "hashArticles"
});

const get_people_hash = (provider) => provider.call({
	"to": MAKE_ADELAIED_ADDRESS,
	"data": "" // computed "
});

const get_articles = async (node, articles_hash) => {
	for await (const article in await node.ls(articles_hash)) {

	}
};

window.addEventListener("onload", (_) => {
	const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545");


});
