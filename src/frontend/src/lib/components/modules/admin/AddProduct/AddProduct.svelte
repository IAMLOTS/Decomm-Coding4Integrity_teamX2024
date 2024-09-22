<script lang="ts">
  import Input from "$lib/components/ui/input/input.svelte";
  import { Label } from "$lib/components/ui/label/";
  import { Textarea } from "$lib/components/ui/textarea/";
  import Dropzone from "svelte-file-dropzone";
  import * as Select from "$lib/components/ui/select";
  import Button from "$lib/components/ui/button/button.svelte";
  import { actorFileUpload } from "$lib/motokoImports/backend";
  import { superForm, defaults } from "sveltekit-superforms/client";
  import { z } from "zod";
  import { zod } from "sveltekit-superforms/adapters";
  import Reload from "svelte-radix/Reload.svelte";
  import { actorBackend } from "$lib/motokoImports/backend";
  import { fullName } from "$lib/data/stores/stores";
  import { toast } from "svelte-sonner";
  import { v4 as uuidv4 } from "uuid";

  let img = "";
  let formSubmitted = false;

  const Currency: any = {
    btc: { btc: null },
    eth: { eth: null },
    icp: { icp: null },
    usd: { usd: null },
    eur: { eur: null },
    gbp: { gbp: null },
    kt: { kt: null },
  };

  interface Price {
    currency: typeof Currency;
    amount: number;
  }

  let files = {
    accepted: [],
    rejected: [],
  };

  const currencies = [{ value: "Knowledge Token", label: "Knowledge Token" }];

  const categories = [
    { value: "Electronics", label: "Electronics" },
    { value: "Clothing", label: "Clothing & Apparel" },
    { value: "Home", label: "Home & Kitchen" },
    { value: "Beauty & Personal Care", label: "Beauty & Personal Care" },
    { value: "Books", label: "Books & Audible" },
    { value: "Toys & Games", label: "Toys & Games" },
    { value: "Sports & Outdoors", label: "Sports & Outdoors" },
    { value: "Automotive", label: "Automotive" },
    { value: "Office Products", label: "Office Products" },
    { value: "Musical Instruments", label: "Musical Instruments" },
  ];

  function handleFilesSelect(e) {
    const { acceptedFiles, fileRejections } = e.detail;
    files.accepted = [...files.accepted, ...acceptedFiles];
    files.rejected = [...files.rejected, ...fileRejections];
  }

  $: selectedCurrency = "KT";
  $: selectedCategory = "Electronics";

  const newContactSchema = z.object({
    Name: z.string().min(2).max(15),
    sDesc: z.string().min(10).max(200),
    lDesc: z.string().min(50).max(2069),
    price: z.number().min(1).max(100000),
  });

  const { form, enhance, constraints } = superForm(
    defaults(zod(newContactSchema)),
    {
      SPA: true,
      validators: zod(newContactSchema),
      onSubmit() {
        formSubmitted = true;
      },
      onUpdated({ form }) {
        uploadImage(
          form.data.Name,
          form.data.price,
          form.data.sDesc,
          form.data.lDesc,
        );
      },
    },
  );

  const uploadChunk = async ({ batch_name, chunk }) => {
    const res = await actorFileUpload.create_chunk({
      batch_name,
      content: [...new Uint8Array(await chunk.arrayBuffer())],
    });

    return res;
  };

  const uploadImage = async (
    formName: any,
    formPrice: any,
    formsDesc: any,
    formlDesc: any,
  ) => {
    if (files.accepted.length === 0) {
      console.error("No files selected");
      return;
    }

    const lastFile = files.accepted[files.accepted.length - 1];
    let batch_name: string;
    let isUnique: boolean = false;
    const promises = [];
    const chunkSize = 500000;

    while (!isUnique) {
      batch_name = await uuidv4();
      isUnique = await actorFileUpload.check_unique(batch_name);
    }

    for (let start = 0; start < lastFile.size; start += chunkSize) {
      const chunk = lastFile.slice(start, start + chunkSize);
      promises.push(await uploadChunk({ batch_name, chunk }));
    }

    const chunkIds = await Promise.all(promises);
    const chunkIdsArray = chunkIds.map((chunk_id) => chunk_id.chunk_id);

    const batch = await actorFileUpload.commit_batch({
      batch_name,
      content_type: lastFile.type,
      chunk_ids: chunkIdsArray,
    });

    const canisterIdFileUpload = import.meta.env.VITE_FILEUPLOAD_CANISTER_ID;
    const host = import.meta.env.VITE_HOST;

    if (import.meta.env.DEV) {
      img =
        `${host}/assets/` + batch_name + `?canisterId=${canisterIdFileUpload}`;
    } else if (import.meta.env.PROD) {
      const stripped = host.replace("https://", "");
      img =
        `https://${canisterIdFileUpload}.` +
        `${stripped}/assets/` +
        batch_name +
        `?canisterId=${canisterIdFileUpload}`;
    }

    try {
      if (selectedCurrency === "Knowledge Token") {
        await actorBackend.createProduct(
          $fullName,
          formName,
          selectedCategory,
          { currency: { kt: null }, amount: Number.parseInt(formPrice) },
          formsDesc,
          formlDesc,
          true,
          img,
        );
      }
      toast.success("Product has been added", {
        description: getFormattedDateTime(),
      });
      formSubmitted = false;
    } catch (err: unknown) {
      console.error(err);
      toast.error("There was an error adding the product. Please try again", {
        description: getFormattedDateTime(),
      });
      formSubmitted = false;
    }
  };

  function getFormattedDateTime() {
    const now = new Date();
    const dayOfWeek = now.toLocaleDateString("en-US", { weekday: "long" });
    const monthDay = now.toLocaleDateString("en-US", {
      month: "long",
      day: "numeric",
    });
    const year = now.getFullYear();
    const time = now.toLocaleTimeString([], {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    });

    return `${dayOfWeek}, ${monthDay} ${year} at ${time}`;
  }
</script>

<div class="pl-2 w-full h-full overflow-hidden">
  <h2 class="text-xl font-semibold mb-5">Add Product</h2>
  <p class="mb-5">
    Fill in the fields below to add your product to the DECOMM customer facing
    website
  </p>
  <hr />
  <form method="POST" use:enhance>
    <div class="grid w-full max-w-sm items-center gap-1.5 mt-5">
      <Label for="Name">Name</Label>
      <Input
        type="text"
        id="Name"
        name="Name"
        bind:value={$form.Name}
        {...$constraints.Name}
      />
      <p class="text-sm text-muted-foreground">
        Enter the name of the desired product you'd like to sell
      </p>
    </div>
    <div class="grid w-full max-w-sm items-center gap-1.5 mt-10">
      <Label for="price">Category</Label>
      <Select.Root
        onSelectedChange={(v) => {
          v && (selectedCategory = v.value);
        }}
      >
        <Select.Trigger class="w-[180px]">
          <Select.Value placeholder="Select a category" />
        </Select.Trigger>
        <Select.Content>
          <Select.Group>
            <Select.Label>Category</Select.Label>
            {#each categories as category}
              <Select.Item value={category.value} label={category.label}
                >{category.label}</Select.Item
              >
            {/each}
          </Select.Group>
        </Select.Content>
        <Select.Input name="favoriteFruit" />
      </Select.Root>
      <p class="text-sm text-muted-foreground">
        Enter the Category for your product.
      </p>
    </div>
    <div class="grid w-full max-w-sm items-center gap-1.5 mt-10">
      <Label for="price">Currency</Label>
      <Select.Root
        onSelectedChange={(v) => {
          v && (selectedCurrency = v.value);
        }}
      >
        <Select.Trigger class="w-[180px]">
          <Select.Value placeholder="Select a currency" />
        </Select.Trigger>
        <Select.Content>
          <Select.Group>
            <Select.Label>Currency</Select.Label>
            {#each currencies as currency}
              <Select.Item value={currency.value} label={currency.label}
                >{currency.label}</Select.Item
              >
            {/each}
          </Select.Group>
        </Select.Content>
        <Select.Input name="favoriteFruit" />
      </Select.Root>
      <p class="text-sm text-muted-foreground">
        Enter the desired Currency you'd like to recieve for your sales.
      </p>
    </div>
    <div class="grid w-full max-w-sm items-center gap-1.5 mt-10">
      <Label for="price">Price</Label>
      {#if selectedCurrency === "Knowledge Token"}
        <Input
          type="number"
          id="price"
          placeholder="120 KT"
          bind:value={$form.price}
          {...$constraints.price}
        />
      {/if}
      <p class="text-sm text-muted-foreground">
        Enter the desired selling price for your product
      </p>
    </div>
    <div class="grid w-full max-w-sm items-center gap-1.5 mt-10">
      <Label for="sDesc">Short Description</Label>
      <Input
        type="text"
        id="sDesc"
        name="sDesc"
        bind:value={$form.sDesc}
        {...$constraints.sDesc}
        placeholder="A car jumper to help start your car"
      />
      <p class="text-sm text-muted-foreground">
        Enter a brief description of the product
      </p>
    </div>
    <div class="grid w-full gap-1.5 mt-10">
      <Label for="lDesk">Full Description</Label>
      <Textarea
        id="lDesc"
        name="lDesc"
        bind:value={$form.lDesc}
        {...$constraints.lDesc}
        placeholder="A portable battery device that allows you to jump start your vehicle. These devices operate similar to jumnper cables but do not require an additional vehicle to provide the power needed to boost the dead vehicle battery. Jump starts using lead-acid batteries that have 1000 amp rating."
      />
      <p class="text-sm text-muted-foreground">
        A longer description of the item you are trying to sell.
      </p>
    </div>
    <div class="grid w-full gap-1.5 mt-16">
      <Label>Insert Product Image</Label>
      <Dropzone on:drop={handleFilesSelect} multiple={false} accept="image/*" />
      <ol>
        {#if files.accepted.length > 0}
          <li>{files.accepted[files.accepted.length - 1].name}</li>
        {/if}
      </ol>
    </div>
    <div class="w-full flex justify-end mt-10">
      {#if !formSubmitted}
        <Button type="submit">Add Product</Button>
      {:else}
        <Button disabled>
          <Reload class="mr-2 h-4 w-4 animate-spin" />
          Adding Product
        </Button>
      {/if}
    </div>
  </form>
</div>
