export default {
	async fetch(request, env, ctx) {
	  const url = new URL(request.url);
	  
	  // Remove the first "/" and handle potential "/video/" prefix
	  let objectKey = url.pathname.replace(/^\//, "");
	  
	  // If the path starts with "video/", remove that prefix too
	  objectKey = objectKey.replace(/^video\//, "");
	  
	  // If the path is empty after removing prefixes, return a 404
	  if (!objectKey) {
		return new Response("Not found", { status: 404 });
	  }
	  
	  console.log(`Attempting to fetch object: ${objectKey}`);
	  
	  try {
		const object = await env.MY_R2_BUCKET.get(objectKey);
		
		if (!object) {
		  return new Response(`Video not found: ${objectKey}`, { status: 404 });
		}
		
		const headers = new Headers();
		headers.set("Content-Type", "video/mp4");
		headers.set("Access-Control-Allow-Origin", "*");
		
		// Add a cache control header to improve performance
		headers.set("Cache-Control", "public, max-age=14400"); // Cache for 4 hours
		
		return new Response(object.body, {
		  status: 200,
		  headers,
		});
	  } catch (error) {
		console.error(`Error fetching object: ${error.message}`);
		return new Response(`Internal server error: ${error.message}`, { status: 500 });
	  }
	},
  };