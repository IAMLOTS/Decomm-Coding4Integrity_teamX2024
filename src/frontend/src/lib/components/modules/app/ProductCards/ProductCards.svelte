<script lang="ts">
  import Card from "$lib/components/modules/app/Card/Card.svelte";
  import { onMount } from "svelte";
  import { actorBackend } from "$lib/motokoImports/backend";
  import { quintOut } from "svelte/easing";

  let posts = false;
  let converted;

  onMount(async () => {
    const resProduct = await actorBackend.getAllProductTypes();
    converted = await convertBigIntToNumber(resProduct);
    posts = true;
  });

  async function convertBigIntToNumber(products: any[]) {
    return products.map((product) => ({
      ...product,
      productPrice: {
        ...product.productPrice,
        amount: Number(product.productPrice.amount),
      },
      productID: Number(product.productID),
    }));
  }

  function combineTransitions(node, { delay = 0, duration = 400 }) {
    return {
      delay,
      duration,
      css: (t) => {
        const eased = quintOut(t);
        return `
                    opacity: ${eased};
                    transform: translate3d(0, ${(1 - eased) * 100}px, 0);
                `;
      },
    };
  }
</script>

<div class="grid grid-cols-12 mt-22 pt-20 lg:pt-0 xl:mt-0 bg-zinc-50 w-full">
  {#if !posts}
    <div
      class="col-span-12 grid grid-cols-12 justify-center items-center w-full h-screen"
    >
      <div
        class="col-span-12 flex h-full w-full justify-center items-center text-3xl lg:text-7xl font-medium animate-pulse-custom"
      >
        Loading Items...
      </div>
    </div>
  {:else if posts && converted.length >= 1}
    <div
      class="min-h-full bg-zinc-50 col-span-12 grid grid-cols-12 justify-center gap-10 lg:mb-0 md:p-8 xl:p-5 2xl:px-40 h-fit w-full overflow-hidden"
      transition:combineTransitions={{ duration: 800 }}
    >
      {#each converted as post, i}
        <div
          class="col-span-12 bg-zinc-50 md:col-span-6 lg:col-span-3 w-full h-1/6 border-zinc-300 {i >=
          4
            ? '2xl:mt-10'
            : '2xl:mt-44'}"
          transition:combineTransitions={{ delay: i * 100, duration: 600 }}
        >
          <Card
            name={post.name}
            productLongDesc={post.productLongDesc}
            productCategory={post.productCategory}
            productShortDesc={post.productShortDesc}
            productID={post.productID}
            isSold={post.isSold}
            isVisible={post.isVisible}
            sellerID={post.sellerID}
            productPrice={post.productPrice}
            productPicture={post.productPicture}
          />
        </div>
      {/each}
    </div>
  {:else if posts && converted.length <= 0}
    <div
      class="col-span-12 grid grid-cols-12 justify-center items-center w-full"
    >
      <div
        class="col-span-12 flex h-full w-full justify-center items-center text-3xl lg:text-7xl font-medium"
      >
        No Products Found....
      </div>
    </div>
  {/if}
</div>
