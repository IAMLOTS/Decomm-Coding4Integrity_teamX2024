<script lang="ts">
  import Search from "./search";
  import {
    loggedIn,
    loginStore,
    accountType,
    cart,
    fullName,
  } from "$lib/data/stores/stores";
  import { goto } from "$app/navigation";
  import * as Select from "$lib/components/ui/select";
  import { Button } from "$lib/components/ui/button";
  import { page } from "$app/stores";
  import { tweened } from "svelte/motion";
  import { IconShoppingCart } from "@tabler/icons-svelte";
  import { onMount } from "svelte";
  import { actorBackend } from "$lib/motokoImports/backend";

  $: innerWidth = 0;
  let sideNavBar = false;

  const scale = tweened(1);
  const translateX = tweened(0);

  function toggleNavBar() {
    sideNavBar = !sideNavBar;
    if (sideNavBar) {
      scale.set(0.9);
      translateX.set(-90);
    } else {
      scale.set(1);
      translateX.set(0);
    }
    document.body.classList.toggle("nav-open", sideNavBar);
  }

  async function goHomeTitle() {
    $accountType.value = "Personal Account";
    await goto("/");
  }

  function closeNav() {
    sideNavBar = false;
    document.body.classList.toggle("nav-open", sideNavBar);
    scrollIntoView("#root");
  }

  function scrollIntoView(target) {
    const el = document.querySelector(target);
    if (!el) return;
    el.scrollIntoView({
      behavior: "smooth",
    });
  }

  function logOut() {
    loggedIn.update((currentValue) => ({ value: false }));
    $accountType.value = "Personal Account";
    $loginStore = true;
    $fullName = "";
    goto("/login");
  }

  async function pAccount() {
    $accountType.value = "Personal Account";
    await goto("/");
  }

  async function bAccount() {
    $accountType.value = "Business Account";
    await goto("/admin");
  }

  async function navPAccount() {
    $accountType.value = "Personal Account";
    await goto("/");
    sideNavBar = false;
    document.body.classList.toggle("nav-open", sideNavBar);
  }

  async function navBAccount() {
    $accountType.value = "Business Account";
    await goto("/admin");
    sideNavBar = false;
    document.body.classList.toggle("nav-open", sideNavBar);
  }

  async function navCart() {
    $accountType.value = "Business Account";
    await goto("/cart");
    sideNavBar = false;
    document.body.classList.toggle("nav-open", sideNavBar);
  }

  onMount(async () => {
    const count = await actorBackend.getUserCartCount($fullName);
    $cart.value = Number(count);
  });
</script>

<svelte:window bind:innerWidth />

<div
  class="text-black fixed lg:hidden inset-0 z-40 top-0 right-0 h-full w-80svw bg-white transform translate-x-full transition-transform duration-300 navbarVisible pointer-events-auto thisIsNav bg-zinc-50"
>
  <div
    class="flex justify-end h-[20%] item-center content-center max-[500px]:mb-10"
    style="width: 80%; overflow: hidden"
  >
    <button
      class="flex justify-center h-full text-6xl text-black cursor-pointer"
      on:click={closeNav}
      aria-label="Close Navigation">&times;</button
    >
  </div>
  <div class="h-[75%]">
    <div
      class="grid grid-rows-4 grid-flow-col gap-10 justify-center items-center content-center h-full text-4xl font-semibold"
    >
      <a href="#homeSection" on:click|preventDefault={navPAccount}
        >Personal Profile &#8594;</a
      >
      <a href="#homeSection" on:click|preventDefault={navBAccount}
        >Business Profile &#8594;</a
      >
      <a href="#homeSection" on:click|preventDefault={navCart}>Cart &#8594;</a>
    </div>
  </div>
  <div></div>
</div>

<header
  class="w-full mx-auto py-3 lg:py-7 z-20 transition-all duration-300 ease-in-out border-b-4 border-zinc-400 top-0 absolute bg-white"
>
  <nav
    class="grid grid-cols-12 gap-4 items-center py-2 text-stone-500 hover:text-stone-500 focus:text-stone-700 lg:py-1 data-te-navbar-ref"
  >
    <div class="col-span-4 lg:col-span-3 lg:flex lg:justify-start">
      <div class="ml-5 lg:ml-10">
        <a
          href="/"
          class="font-bold text-xl lg:text-2xl text-black hover:cursor-pointer active:text-black/50"
          on:click|preventDefault={goHomeTitle}
          >D&nbspE&nbspC&nbspO&nbspM&nbspM</a
        >
      </div>
    </div>
    <div
      class="col-span-8 lg:col-span-6 flex pl-5 lg:pl-0 lg:justify-center min-w-full justify-end"
    >
      {#if $accountType.value === "Personal Account" && $page.url.pathname === "/" && innerWidth > 1024}
        <Search />
      {/if}
      <div class="col-span-12 lg:hidden content-end flex justify-end mr-5">
        <button aria-label="Toggle navigation" on:click={toggleNavBar}>
          <div class="w-6 h-1 my-1 bg-stone-900"></div>
          <div class="w-6 h-1 my-1 bg-stone-900"></div>
          <div class="w-6 h-1 bg-black"></div>
        </button>
      </div>
    </div>
    <div
      class="hidden lg:col-span-3 lg:flex justify-end lg:mr-10 gap-x-5 inset-0"
    >
      {#key $accountType.value}
        <Select.Root>
          <Select.Trigger class="w-[180px] font-medium h-[40px]">
            <Select.Value placeholder={$accountType.value} />
          </Select.Trigger>
          <Select.Content class="shadow-lg backdrop-blur-xl">
            <p class="text-sm text-center my-3">{$fullName}</p>
            <hr />
            <Select.Item value="Personal Account" on:click={pAccount}
              >Personal Account</Select.Item
            >
            <Select.Item value="Business Account" on:click={bAccount}
              >Business Account</Select.Item
            >
            <hr />
            <Button class="ghost w-full h-full" on:click={logOut}
              >Log Out</Button
            >
          </Select.Content>
        </Select.Root>
      {/key}
      <div>
        <button
          class="hover:bg-zinc-200 hover:rounded-lg flex items-center justify-center cursor-pointer"
          on:click={() => goto("/cart")}
        >
          <IconShoppingCart size={48} stroke={1} color={"#71717a"} />
          <div
            class="absolute top-[2.54rem] right-[3.25rem] flex items-center justify-center w-5 h-5 text-zinc-500 text-xs font-bold rounded-full"
          >
            {$cart.value}
          </div>
        </button>
      </div>
    </div>
  </nav>
</header>

{#if $accountType.value === "Personal Account" && $page.url.pathname === "/" && innerWidth < 1024}
  <div
    class="fixed bottom-0 bg-white z-20 w-full border-t-2 border-zinc-300 p-2"
  >
    <div class="w-full flex justify-center items-center">
      <Search />
    </div>
  </div>
{/if}
