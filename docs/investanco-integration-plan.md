# Plano de Integração — Trazer as capacidades de investimento do Investanco para o Financo

> Documento de decisão. Investanco permanece intacto; portamos **para dentro** do Financo, substituindo o módulo `lib/features/investments/` (tracking-only, Model A). Fonte: auditorias paralelas de ambos os codebases (7 agentes, 2026-07-22). Financo é spec-driven — cada fase escreve `docs/specs/<feature>.md` **antes** de código.

> **Artefato histórico — congelado em 2026-07-22.** O que foi de fato construído
> está em `docs/specs/investing.md` e nas specs por feature; quando os dois
> divergem, a spec vence. Duas divergências já conhecidas:
> **(a)** "`formatCurrency(double)` … vira `formatCurrency(Money)` … overload"
> (§1 do quadro Core Money e a linha F0) nunca foi implementável — Dart não tem
> sobrecarga de função. O que existe é `formatMoney(Money)` ao lado de
> `formatCurrency(double, [Currency = brl])`.
> **(b)** A resolução "desacoplar investimento da conta" foi **revertida** em
> 2026-07-25 pela decisão D1 de
> [investing_account_unification.md](specs/investing_account_unification.md): a
> `Institution` passou a ser o único registro de "conta de investimento".

---

## 0. Notas do CTO (revisão do plano)

Revisão pessoal sobre o plano sintetizado abaixo. Concordo com as três resoluções centrais (desacoplar investimento da conta; adotar `Money`/`Currency`; manter `asset_classes`, matar `asset_holdings`). Ajustes/alertas:

1. **Escopo do `Money` (refino da 2ª tensão).** O resto do Financo (accounts, transactions de caixa, budgets) roda em `double` BRL. Converter o app **inteiro** para `Money` é blast-radius enorme e desnecessário para o objetivo. Recomendo **`Money`/`Currency` só no módulo de investimento**; `formatCurrency` ganha overload multimoeda sem reescrever os ~15 call-sites de caixa. Vira decisão explícita (§7, nova pergunta 9).
2. **Confirmar `schemaVersion` real na F0.** O plano estima `11→12`; a spec de investimentos original citava `6→7` (2026-05-18). O número exato sai de ler o `AppDatabase` atual antes de escrever a migração — não assumir.
3. **Esforço realista.** Mesmo com reuso quase literal, F1 (modelo+persistência) e F2 (quotes+valuation) são as duas fases **L** e carregam o risco. Isto é trabalho de semanas, não dias — o ganho é que ~80% é port, não invenção.
4. **Ordem de valor.** Se o objetivo for provar valor cedo: F0→F1→F3 (registrar compra/venda) já entrega "eu tenho X ações"; F2/F4 (cotação + patrimônio multimoeda) é o que te dá o "quanto vale hoje". Não dá pra pular F2 se multimoeda é requisito — mas dá pra entregar F3 antes e valorizar depois.

---

## 1. Resumo executivo

- **Trazer (reuso direto, mesmo stack):** o modelo de eventos `Institution → Asset → AssetTransaction → Holding(derivado)`, o `HoldingCalculator` puro, o núcleo `Money`/`Currency` (cents inteiros, multimoeda BRL/USD/EUR), o motor de cotação/FX/índices (brapi, CoinGecko, Finnhub, Tesouro, BCB, AwesomeAPI), a `ValuationService` (inclui renda fixa por fluxos de caixa datados), os `Snapshots` diários e o import CSV. Isso é código já escrito e testado — porta com adaptação, não reescrita.
- **Descartar:** o módulo atual de investimentos do Financo por inteiro (`asset_holding_entity` com `amount` manual em BRL), o invariante Model-A "teto de saldo" e as migrações incrementais versionadas do Investanco (o Financo usa cache Drift descartável drop-recreate).
- **Preservar e evoluir:** `asset_classes` do Financo — é o **mesmo conceito** de classe de alocação do Investanco (`AssetClasses`); sobrevive. Apenas `asset_holdings` morre.
- **Tensão arquitetural central:** o módulo atual amarra investimento ao saldo de conta (`Σ holdings.amount ≤ account.effectiveBalance`, principal-only). Valor de mercado real quebra isso — carteiras valorizam acima do principal. **Resolução:** desacoplar o investimento da conta. Holdings passam a derivar de `AssetTransaction` + cotação; `totalInvested`/valor de mercado deixam de vir de `account.effectiveBalance`. O invariante do teto é **removido**.
- **Segunda tensão (dinheiro):** Investanco = `Money(minorUnits, Currency)` multimoeda; Financo = `double` BRL. **Resolução recomendada:** adotar `Money`/`Currency` do Investanco no core do Financo (correção > lossy). O `formatCurrency` BRL-only vira multimoeda. *(CTO: escopar só no módulo de investimento — ver §0.1.)*
- **Terceira tensão (persistência):** ambos já são local-first Drift + Firestore-como-verdade, write-through, pull autoritativo no login — filosofia **já alinhada**. Adotar a mecânica do Financo (coleções top-level com campo `userId`, `RemoteDataSource` por feature, cache descartável), renomeando coleções que colidem.
- **Camada de mercado (decisão a confirmar):** recomendo **proxy via Cloud Functions apenas para as fontes com chave** (brapi, Finnhub — o Financo já roteia Gemini por Functions), mantendo as sem-chave (CoinGecko, Tesouro, BCB, AwesomeAPI) client-side com `dio`. Alternativa mais rápida para MVP: tudo client-side como no Investanco (chaves são free-tier de baixo valor). Ver §4 e §7.

---

## 2. Estado atual dos dois lados

| Capacidade | Financo (o que é hoje) | Investanco (o que tem a mais) |
|---|---|---|
| **Modelo de holding** | `AssetHoldingEntity`: `amount` (double, BRL) declarado à mão; sem ticker/quantidade/preço | `Holding` **derivado** de `AssetTransaction` (buy/sell/dividend) via `HoldingCalculator`; qtd, custo médio ponderado, P/L realizado, dividendos |
| **Compra/venda real** | ❌ nunca escreve transação; só rótulo de `amount` | ✅ `AssetTransaction{kind: buy/sell/dividend, quantity, unitPrice, fees, amount}`; guarda de oversell na timeline |
| **Cotação / valor de mercado** | ❌ inexistente | ✅ brapi (BR), CoinGecko (cripto), Finnhub (US), Tesouro Direto, valor de mercado = `qtd × preço` |
| **Multimoeda** | ❌ `formatCurrency` trava BRL, `double` | ✅ `Currency{brl,usd,eur}`, moeda nativa por ativo, consolidação FX na valoração (AwesomeAPI) |
| **Patrimônio histórico** | ❌ sem snapshots | ✅ `Snapshots` diários (id `yyyy-MM-dd`), `totalValue/Invested/PL`, gravados no refresh do dashboard |
| **Valuation renda fixa** | ❌ | ✅ fluxos de caixa datados + accrual CDI/Selic/prefixado/IPCA (séries BCB SGS) |
| **Import CSV** | (import por entidade existe no app) | ✅ import de ativos e de transações, autodetecção de encoding, sinônimos PT/EN de header |
| **Instituições (custódia)** | ❌ (só `accounts`) | ✅ `Institution{name,kind,currency}`; ativo aponta 1 instituição |
| **Alocação/rebalance** | ✅ `asset_classes` + overview/rebalance (mas sobre principal, não mercado) | ✅ mesmo conceito, porém % e ações de rebalance sobre **valor de mercado** |

**Gap preciso:** o Financo sabe *classificar* dinheiro que o usuário digitou; não sabe *o que* ele possui, *quanto vale hoje*, *em qual moeda*, nem *como evoluiu*. Todo o motor transacional + cotação + FX + snapshots + renda fixa é o que se importa.

---

## 3. Modelo de dados alvo no Financo

### Decisões de reconciliação

1. **`asset_classes` SOBREVIVE.** É o mesmo conceito nas duas bases (classe de alocação com `targetPercent`, `parentId`). Manter a coleção/entidade do Financo (`asset_class_entity.dart`: `id,userId,name,icon(int),color(int),targetPercent,parentId,createdAt`). *Investigar:* Financo usa `icon:int`/`color:int`; Investanco usa `iconKey:string`/`colorValue:int` — decidir representação única (recomendo manter os inteiros do Financo e mapear os ícones do Investanco no port).
2. **`asset_holdings` MORRE.** `amount` manual é inconvertível (sem ticker/quantidade). Substituído por `Asset` + `AssetTransaction` + `Holding` derivado.
3. **Instituição = coleção NOVA e irmã, NÃO vira `Account`.** Custódia (Nubank/Avenue/Wise, com moeda) é conceito distinto do ledger de caixa `Account`. Sobrecarregar `Account` acoplaria de novo. Mantê-las separadas torna o módulo de investimento autocontido.
4. **`AccountType.investment` permanece só para o 50/30/20** (tag de aportes/poupança). **Não hospeda mais holdings.** O invariante Model-A (`Σ holdings.amount ≤ account.effectiveBalance` em `create_asset_holding_usecase.dart:82-98` e `compute_investment_overview.dart:79-97`) é **removido**. Valor de mercado passa a viver no novo ledger, desacoplado do principal de `account_balance_calculator.dart`.
5. **Moeda:** viaja dentro de cada `Money`; no nível de entidade em `Asset.currency` (nativa) e `Institution.currency` (default). Transação guarda **uma** coluna `currency` reaplicada aos 3 campos Money.
6. **Vínculo de alocação** fica na **`Asset.metadata`** (`allocationClassId`, `allocationTargetPercent`) como no Investanco — não é FK. `metadata:Map<String,String>` também carrega `fiBasis`/`fiRate`/`tesouroName`/`coingeckoId`.

### Coleções Firestore alvo (top-level, escopadas por `userId`, renomeadas p/ evitar colisão)

| Coleção | Origem | Nota de colisão |
|---|---|---|
| `asset_classes/{id}` | Financo (mantida) | — |
| `institutions/{id}` | novo (Investanco) | — |
| `investment_assets/{id}` | Investanco `assets` | Financo não tem `assets`; namespaced por clareza |
| `investment_transactions/{id}` | Investanco `transactions` | **colide** com `transactions/{id}` do Financo → renomear |
| `investment_snapshots/{id}` | novo (Investanco `snapshots`) | id = `yyyy-MM-dd` |

Cada doc grava via `RemoteDataSource`/model com `toFirestore()`/`fromFirestore()` explícito e **campo `userId`** (padrão Financo), não `row.toJson()` cru sob `users/{uid}/...` (padrão Investanco). `asset_holdings/{id}` é removida das regras.

### Tabelas Drift alvo — `schemaVersion N → N+1` *(confirmar N real na F0)*

Cache descartável (drop-recreate no `onUpgrade`; sem migração de coluna). Adicionar a `allTables`/`daos`, **remover `LocalAssetHoldings`/`AssetHoldingsDao`**:

- **Mirrored (têm `userId`):** `Institutions`, `InvestmentAssets` (id, ticker, name, kind, market, currency, institutionId, metadata TEXT default `{}`, createdAt, userId), `InvestmentTransactions` (id, institutionId, assetId, kind, quantity REAL, unitPriceMinor INT, feesMinor INT, amountMinor INT, currency, date, notes?, createdAt, updatedAt, userId), `InvestmentSnapshots` (id `yyyy-MM-dd`, date, totalValueMinor, totalInvestedMinor, totalPlMinor, currency, userId), e a mantida `LocalAssetClasses`.
- **Não-mirrored (cache de mercado, device-local):** `Quotes` (assetId, unitPriceMinor, previousCloseMinor?, currency, asOf, fetchedAt, source), `FxRates` (pair, rate, fetchedAt), `IndexPoints` (index, date, rate). `Settings.baseCurrency` — *investigar* se o Financo já tem tabela `settings`; se não, adicionar linha única id=0.
- **DAOs novos:** `InstitutionsDao`, `InvestmentAssetsDao`, `InvestmentTransactionsDao`, `InvestmentSnapshotsDao`, `QuotesDao`, `FxRatesDao`, `IndexPointsDao` (Financo exige DAOs; Investanco batia `_db` direto).

**`Holding` nunca é persistido** — derivado por `HoldingCalculator`.

---

## 4. Arquitetura de integração

| Camada | Decisão |
|---|---|
| **Core Money** | Portar `lib/core/money/{money,currency}.dart` do Investanco para o Financo. `formatCurrency(double)` BRL-only vira `formatCurrency(Money)` multimoeda (`NumberFormat.currency(locale: ccy.locale, symbol: ccy.symbol)`); ~15 call-sites atuais recebem overload/adapter. |
| **DI** | Escada `get_it` existente em `injection_container.dart` (External→DAOs→Datasources→Repos→UseCases→Cubits). Registrar repos como `registerLazySingleton<Interface>`. `PortfolioPricingEngine` composto por-cubit (não registrado), como no Investanco. |
| **Routing/Shell** | Manter rotas do Financo (`/investments`, `/investments/class/:id`) dentro da `ShellRoute`. **Não** adotar a landing tab `/allocation` do Investanco (Financo abre no dashboard). O cubit de sessão substituto pluga no seam do shell (`app_router.dart:216-225`), recebendo `userId` resolvido do `AuthBloc.state` no mount — mantém a convenção de lifecycle do CLAUDE.md. |
| **Drift migration** | bump `schemaVersion`; drop-recreate. Descartar as migrações incrementais v2–v10 do Investanco (esforço perdido sob o modelo descartável). `LocalAssetHoldings` sai de `allTables`. |
| **Firestore rules** | Adicionar `institutions`, `investment_assets`, `investment_transactions`, `investment_snapshots` com o padrão existente (`isAllowed() && ownsCreate()` / `ownsResource() || isMaster()`). Remover regras de `asset_holdings`. Gate de acesso permanece `allowed_emails/{email}` do Financo — **descartar** o `_ownerEmails` const hard-coded do Investanco. |
| **i18n (slang)** | Estender namespace `investments` em `en.i18n.json` + `pt-BR.i18n.json`, `dart run slang`. Portar labels de asset/transaction/allocation/instituição. |
| **Persistência (modelo alvo)** | **Firestore-primário** (padrão Financo): write-through por `RemoteDataSource` por feature + campo `userId`; pull autoritativo full no login via `SyncService.fullSync`; sem push/tombstone; online-first. Descartar o port único `RemoteMirror`/`guardedMirroredUpsert` do Investanco em favor da consistência com o resto do Financo. Filosofia idêntica — só a mecânica conforma. |
| **Camada de mercado / FX** | **Recomendação:** proxy **Cloud Functions** para as fontes **com chave** (brapi `BRAPI_TOKEN`, Finnhub `FINNHUB_TOKEN`) — alinha com a postura server-side do Financo (Gemini já em Functions) e esconde as únicas chaves reais. Fontes **sem chave** (CoinGecko, Tesouro, BCB, AwesomeAPI/FX) ficam **client-side com `dio`** (reuso direto dos adapters). Trade-off: o proxy é **trabalho novo** que não existe no Investanco. **Alternativa MVP:** tudo client-side via `dio` como no Investanco (chaves free-tier embutidas no bundle JS — baixo valor, aceitável), com hardening depois. **Confirmar em §7.** |
| **Segredos** | `BRAPI_TOKEN`/`FINNHUB_TOKEN` universais, hoje `String.fromEnvironment` via `--dart-define-from-file=env.json`. Se forem para Functions, viram secrets do backend (não vão no bundle). Demais fontes: sem chave. |
| **Rate limit** | Finnhub free = 60 req/min e é **1 req por símbolo em série** — risco com muitas posições US. Sem backoff hoje (deferido). Tratar no design do proxy/adapter. |

---

## 5. Estratégia de migração / coexistência

- **Dados existentes:** `asset_classes` **preservadas** (mesmo shape). `asset_holdings` existentes são **inconvertíveis** (só têm `amount`, sem ticker/quantidade/preço) — não há como derivar posições reais. **Decisão recomendada:** descartar os `asset_holdings` na virada, comunicando ao usuário que reintroduza posições via transações/import CSV. (Base de usuários é essencialmente single-owner — impacto pequeno; *confirmar*.)
- **Faseado, não big-bang.** O módulo novo é construído em paralelo (F0–F6) atrás de **feature flag** (`kInvestingV2`), enquanto o módulo antigo continua servindo `/investments`. Na F7, a flag vira, a rota aponta para as telas novas e o código antigo + `asset_holdings` são removidos.
- **Cross-feature seams a preservar/religar:** o cascade de deleção de conta (`delete_account_with_dependents_usecase.dart:69` chama `_holdings.deleteHoldingsForAccount`) precisa ser **removido/religado** — com holdings desacoplados de conta, esse cascade some (ou vira no-op). O `refresh` do cubit de sessão consumido pelo `AccountsPage` deve manter assinatura compatível.

---

## 6. Plano faseado

| Fase | Objetivo | Entregáveis-chave | Specs a escrever | Foco de teste | Esforço |
|---|---|---|---|---|---|
| **F0 — Scaffolding** | Base multimoeda + deps + flag | Portar `core/money/{money,currency}`; `formatCurrency(Money)`; deps `dio`; flag `kInvestingV2`; bump `schemaVersion`; namespace i18n | `docs/specs/investing.md` (modelo alvo + remoção do Model-A) | `Money` ±, mismatch de moeda, `fromMajor`, formatter por locale | **S** |
| **F1 — Modelo + persistência** | Ledger de eventos e cache | Entidades `Institution/Asset/AssetTransaction/Holding`; `HoldingCalculator`; `oversell_check`; `transaction_amounts`; tabelas+DAOs Drift; `RemoteDataSource`+models por coleção; rules; remover `asset_holdings` | `investing_data_model.md`, `institutions.md`, `cloud_sync_investing.md` | `HoldingCalculator.derive` (avg cost, realized P/L, re-buy pós-close), oversell timeline, validações de repo (duplicate, mismatch, future date) | **L** |
| **F2 — Cotações / FX** | Preço e câmbio | Adapters brapi/CoinGecko/Finnhub/Tesouro/BCB/AwesomeAPI; `Caching{Fx,Index}DataSource`; `QuoteRepositoryImpl`; `DriftMarketCacheStore`; **decisão proxy vs client-side**; `ValuationService` (inclui renda fixa por fluxos + accrual) | `quotes.md`, `fx.md`, `valuation.md`, `fixed_income.md` | roteamento por `supports()`, TTL/freshness (15min refresh, 1h stale), FX por moeda (USD≠EUR), accrual CDI/prefixado/IPCA, `fxMissing` skip | **L** |
| **F3 — Compra/venda** | Registrar transações | `TransactionFormSheet` (buy/sell/dividend, instituição herdada do ativo); CRUD via cubit; guarda de oversell no write | `transactions_investing.md` | form→amount por kind, oversell backdated, dividend qtd 0 | **M** |
| **F4 — Patrimônio multimoeda + snapshots** | Net worth consolidado + histórico | `PortfolioPricingEngine` (warmStart, refreshNetwork); `PortfolioValuation` (`byCurrency/byClass/byInstitution`); dashboard hero multimoeda; `Snapshots` diários (`upsertToday`, best-effort mirror) | `dashboard_investing.md`, `snapshots.md` | agregação com `fxMissing` skip mas subtotal nativo mantido, snapshot idempotente por dia, skip sem posição fresca | **L** |
| **F5 — Alocação / rebalance** | Overview sobre valor de mercado | Reconciliar `asset_classes` (ícone int↔key); vínculo em `Asset.metadata`; donut + `RebalanceRow` (buy/sell) sobre market value; class detail | `allocation_investing.md` | targets somam 100±0.1, ações de rebalance por delta, sugestão em BRL+nativo | **M** |
| **F6 — Import CSV** | Onboarding de dados | `runCsvImport` genérico; parsers ativos/transações (sinônimos PT/EN, encoding auto); preview pages; samples | `csv_import_investing.md` | header sinônimos, número BR/EN, oversell ordering no import, ativo/instituição match | **M** |
| **F7 — Cleanup** | Remover o antigo | Deletar `lib/features/investments/` antigo; virar flag; religar cascade de conta; reescrever `docs/specs/investments.md` para V2; remover `asset_holdings` de rules/Drift | (atualizar `investments.md` → V2) | regressão de navegação/shell, 50/30/20 intacto | **M** |

---

## 7. Riscos & decisões abertas (precisam da sua chamada)

**Riscos**
- Finnhub serial 1-req/símbolo + free-tier 60/min → falha silenciosa com muitas posições US; sem backoff hoje.
- Chaves client-side ficam legíveis no bundle web (se não usar proxy).
- `formatCurrency` BRL-only tem ~15 call-sites acoplados — refactor transversal.
- Remover o teto Model-A toca `account_balance_calculator`, dashboard e 50/30/20 (que hoje tratam `investment` como checking).
- `asset_holdings` existentes se perdem (inconvertíveis).

**Decisões TRAVADAS (2026-07-22)**
1. **Camada de mercado:** ✅ **proxy Cloud Functions para as fontes com chave** (brapi `BRAPI_TOKEN`, Finnhub `FINNHUB_TOKEN`); keyless (CoinGecko, Tesouro, BCB, AwesomeAPI) client-side com `dio`. Chaves viram secrets do backend, não vão no bundle.
2. **Instituição:** ✅ coleção nova irmã (`institutions/{id}`) — não sobrecarrega `Account`. *(default)*
3. **Migração de `asset_holdings`:** ✅ **descartar** na virada; usuário reintroduz via transação/CSV. Base single-owner.
4. **Base currency:** ✅ BRL fixo na V2 (switcher deferido). *(default)*
5. **Ícone/cor de `asset_classes`:** ✅ manter `int` do Financo; mapear ícones do Investanco no port. *(default)*
6. **Custo:** ✅ custo médio ponderado (Investanco v1); FIFO fora de escopo. *(default)*
7. **`AccountType.investment`:** ✅ manter só para 50/30/20; não hospeda holdings. *(default)*
8. **Roll-out:** ✅ **faseado atrás de `kInvestingV2`**; vira a flag e remove o antigo na F7.
9. **(CTO) Escopo do `Money`:** ✅ **só no módulo de investimento**; resto do Financo segue `double` BRL. `formatCurrency` ganha overload multimoeda — sem refactor transversal dos ~15 call-sites de caixa.

> Consequência da #1: F2 passa a incluir **entregável de backend** (2 endpoints proxy em `functions/`), não só adapters client-side. Consequência da #9: o risco "refactor transversal do `formatCurrency`" (§Riscos) cai — vira overload aditivo.

---

## 8. Recomendação de primeiro passo

Escrever **`docs/specs/investing.md`** — a spec guarda-chuva que fixa o modelo de dados reconciliado (§3), a **remoção explícita do invariante Model-A** e as respostas às decisões abertas. Financo é spec-driven: nada de código antes da spec. Essa spec destrava a F0 (portar `core/money/` + flag `kInvestingV2` + bump `schemaVersion`), que é reuso quase literal e baixo risco.
