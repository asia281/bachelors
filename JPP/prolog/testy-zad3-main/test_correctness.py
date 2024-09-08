from enum import Enum
import os
import random
import subprocess
import sys
from typing import Dict, NamedTuple, Optional, Tuple, List, Union


class BColors:
    OKGREEN = "\033[92m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"


class Directionality(Enum):
    ONE_WAY = "jeden"
    TWO_WAY = "oba"

    def __str__(self) -> str:
        return self.value


class Direction(Enum):
    FORWARDS = 1
    BACKWARDS = 2


class Route(NamedTuple):
    id: str
    begin: str
    end: str
    kind: str
    dir: Directionality
    distance: int

    def __str__(self) -> str:
        return f"trasa({self.id}, {self.begin}, {self.end}, {self.kind}, {self.dir}, {self.distance})."


class Edge(NamedTuple):
    route_id: str
    begin: str
    end: str
    kind: str
    dir: Direction
    distance: int

    @property
    def id(self) -> Tuple[str, Direction]:
        return (self.route_id, self.dir)


class Graph:
    def __init__(self, routes: List[Route]):
        self.routes = routes
        self._neighbours: Dict[str, List[Edge]] = {}
        for route in routes:
            assert route.begin != route.end

            if route.begin not in self._neighbours:
                self._neighbours[route.begin] = []
            self._neighbours[route.begin] += [
                Edge(
                    route.id,
                    route.begin,
                    route.end,
                    route.kind,
                    Direction.FORWARDS,
                    route.distance,
                )
            ]
            if route.dir == Directionality.TWO_WAY:
                if route.end not in self._neighbours:
                    self._neighbours[route.end] = []
                self._neighbours[route.end] += [
                    Edge(
                        route.id,
                        route.end,
                        route.begin,
                        route.kind,
                        Direction.BACKWARDS,
                        route.distance,
                    )
                ]

    def __str__(self) -> str:
        return "\n".join(map(str, self.routes)) + "\n"

    def neighbours(self, location: str) -> List[Edge]:
        return self._neighbours.get(location, [])


class RandomGraph(Graph):
    def __init__(
        self,
        vertices: int,
        edges: int,
        kinds: int = 3,
        max_length: int = 10,
        seed: int = 0,
        one_way_p: float = 0.5,
    ):
        rng = random.Random(seed)

        assert vertices >= 2
        begin = rng.randint(1, vertices - 1)
        end = rng.randint(begin + 1, vertices)
        if rng.randint(0, 1) == 1:
            begin, end = end, begin

        super().__init__(
            [
                Route(
                    id=str(i),
                    begin=str(begin),
                    end=str(end),
                    kind=str(rng.randint(1, kinds)),
                    dir=Directionality.ONE_WAY
                    if rng.random() < one_way_p
                    else Directionality.TWO_WAY,
                    distance=rng.randint(1, max_length),
                )
                for i in range(edges)
            ]
        )


class Comp(Enum):
    LESS = 0
    LESS_EQUAL = 1
    EQUAL = 2
    GREATER_EQUAL = 3
    GREATER = 4

    def check(self, a: int, b: int) -> bool:
        return {
            Comp.LESS: a < b,
            Comp.LESS_EQUAL: a <= b,
            Comp.EQUAL: a == b,
            Comp.GREATER_EQUAL: a >= b,
            Comp.GREATER: a > b,
        }[self]

    def __str__(self) -> str:
        return {
            Comp.LESS: "lt",
            Comp.LESS_EQUAL: "le",
            Comp.EQUAL: "eq",
            Comp.GREATER_EQUAL: "ge",
            Comp.GREATER: "gt",
        }[self]


class Length(NamedTuple):
    op: Comp
    k: int

    def __str__(self) -> str:
        return f"dlugosc({str(self.op)}, {self.k})"

    def check(self, length: int) -> bool:
        return self.op.check(length, self.k)


class Kind(NamedTuple):
    kind: str

    def __str__(self) -> str:
        return f"rodzaj({self.kind})"

    def check(self, kind: str) -> bool:
        return self.kind == kind


Condition = Union[Length, Kind]


class Trip(NamedTuple):
    edges: List[Edge]

    @property
    def length(self) -> int:
        return sum(e.distance for e in self.edges)

    def __str__(self) -> str:
        return (
            self.edges[0].begin
            + " "
            + " ".join(f"-({e.route_id},{e.kind})-> {e.end}" for e in self.edges)
            + f"\nDlugosc trasy: {self.length}."
        )


class Query(NamedTuple):
    source: Optional[str]
    destination: Optional[str]
    conditions: List[Condition]

    def assert_validity_for(self, graph: Graph) -> None:
        assert self.source is None or self.source in graph._neighbours
        assert self.destination is None or self.destination in graph._neighbours

        graph_kinds = set(r.kind for r in graph.routes)
        for c in self.kind_conditions:
            assert c.kind in graph_kinds

    @property
    def length_conditions(self) -> List[Length]:
        return list(filter(lambda x: isinstance(x, Length), self.conditions))

    @property
    def kind_conditions(self) -> List[Kind]:
        return list(filter(lambda x: isinstance(x, Kind), self.conditions))

    def _check_kind(self, kind: str) -> bool:
        return (
            any(c.check(kind) for c in self.kind_conditions)
            if self.kind_conditions
            else True
        )

    def _check_length(self, length: int) -> bool:
        return all(c.check(length) for c in self.length_conditions)

    def __str__(self) -> str:
        return (
            (self.source if self.source else "nil")
            + ".\n"
            + (self.destination if self.destination else "nil")
            + ".\n"
            + (", ".join(map(str, self.conditions)) if self.conditions else "nil")
            + ".\n"
        )

    def solve(self, graph: Graph) -> List[Trip]:
        trips = []
        visited = set()

        def dfs(current: str, current_trip: Trip = Trip([])) -> None:
            if (
                (not self.destination or current == self.destination)
                and self._check_length(current_trip.length)
                and current_trip.edges
            ):
                trips.append(current_trip)
            for edge in graph.neighbours(current):
                if edge not in visited and self._check_kind(edge.kind):
                    visited.add(edge)
                    dfs(edge.end, Trip(current_trip.edges + [edge]))
                    visited.remove(edge)

        if self.source:
            dfs(self.source)
        else:
            for source in graph._neighbours.keys():
                dfs(source)

        return trips


def random_query(
    vertices: List[str],
    kinds: List[str],
    max_conditions: int = 3,
    max_length: int = 10,
    seed: int = 0,
    no_nils: bool = False,
):
    rng = random.Random(seed)

    conditions: List[Condition] = []
    conditions_cnt = rng.randint(0, max_conditions)
    if conditions_cnt and rng.randint(0, 1) == 1:
        conditions = [Length(op=Comp(rng.randint(0, 4)), k=rng.randint(1, max_length))]

    conditions += [
        Kind(kind=rng.choice(kinds)) for _ in range(conditions_cnt - len(conditions))
    ]

    return Query(
        source=rng.choice(vertices) if no_nils or rng.randint(0, 1) == 1 else None,
        destination=rng.choice(vertices) if no_nils or rng.randint(0, 1) == 1 else None,
        conditions=conditions,
    )


def random_queries(
    count: int,
    vertices: List[str],
    kinds: List[str],
    max_conditions: int = 3,
    max_length: int = 10,
    seed: int = 0,
    no_nils: bool = False,
) -> List[Query]:
    rng = random.Random(seed)

    return [
        random_query(
            vertices=vertices,
            kinds=kinds,
            max_conditions=max_conditions,
            max_length=max_length,
            seed=rng.randint(0, 1000000),
            no_nils=no_nils,
        )
        for _ in range(count)
    ]


sample_graph = Graph(
    [
        Route("r1", "zakopane", "brzeziny", "rower", Directionality.TWO_WAY, 25),
        Route("r2", "brzeziny", "gasienicowa", "rower", Directionality.TWO_WAY, 15),
        Route("r3", "brzeziny", "poroniec", "rower", Directionality.TWO_WAY, 10),
        Route("r4", "poroniec", "rusinowa", "rower", Directionality.TWO_WAY, 6),
        Route("g1", "zakopane", "kuznice", "spacer", Directionality.TWO_WAY, 7),
        Route("g2", "zakopane", "kalatowki", "gorska", Directionality.TWO_WAY, 5),
        Route("g3", "kuznice", "gasienicowa", "gorska", Directionality.TWO_WAY, 7),
        Route("g4", "gasienicowa", "zawrat", "gorska", Directionality.TWO_WAY, 6),
        Route("g5", "gasienicowa", "czarnystaw", "gorska", Directionality.TWO_WAY, 3),
        Route("g6", "zawrat", "kozia", "gorska", Directionality.ONE_WAY, 5),
        Route("g7", "kozia", "gasienicowa", "gorska", Directionality.ONE_WAY, 7),
        Route("p1", "zakopane", "gubalowka", "piesza", Directionality.TWO_WAY, 5),
    ]
)

small_path = Graph(
    [
        Route("1", "1", "2", "a", Directionality.TWO_WAY, 25),
        Route("2", "2", "3", "a", Directionality.TWO_WAY, 15),
        Route("3", "3", "4", "b", Directionality.ONE_WAY, 10),
        Route("4", "4", "5", "a", Directionality.TWO_WAY, 6),
    ]
)

cycle5 = Graph(
    [
        Route("1", "1", "2", "a", Directionality.ONE_WAY, 1),
        Route("2", "2", "3", "a", Directionality.ONE_WAY, 1),
        Route("3", "3", "4", "a", Directionality.ONE_WAY, 1),
        Route("4", "4", "5", "a", Directionality.ONE_WAY, 1),
        Route("5", "5", "1", "a", Directionality.ONE_WAY, 1),
    ]
)


class Test:
    OUTPUT_DUMP = "test_output"
    EXPECTED_DUMP = "test_expected"

    def __init__(self, name: str, graph: Graph, query: Query) -> None:
        self.name = name
        self.graph = graph
        self.query = query

        query.assert_validity_for(graph)

        try:
            os.remove(self.OUTPUT_DUMP)
            os.remove(self.EXPECTED_DUMP)
        except OSError:
            pass

    def _check_output(
        self, output: str, expected_trip_strs: List[str]
    ) -> Optional[str]:
        output_lines = list(
            filter(
                lambda x: x != ""
                and not "Podaj miejsce" in x
                and not "Podaj warunki" in x
                and not "Koniec programu" in x,
                output.splitlines(),
            )
        )

        if len(output_lines) % 2 != 0:
            return f"Number of lines containing trips in the output is not even: {len(output_lines)}."
        all_output_trip_strs = [
            output_lines[i] + "\n" + output_lines[i + 1]
            for i in range(0, len(output_lines), 2)
        ]

        if sorted(all_output_trip_strs) != sorted(list(set(expected_trip_strs))):
            return "Output does not match expected output."

        return None

    def _dump_test(self, output: str, expected_trip_strs: List[str]) -> None:
        print(f"Query content:\n{str(self.query)}")
        print(f"Graph saved in {TestGroup.ROUTES_FILE}.")

        output_file = open(self.OUTPUT_DUMP, "w")
        output_file.write(output)
        output_file.close()
        print(f"Solution output saved in {self.OUTPUT_DUMP}.")

        expected_file = open(self.EXPECTED_DUMP, "w")
        expected_file.write("\n\n".join(set(expected_trip_strs)))
        expected_file.close()
        print(f"Expected trips saved in {self.EXPECTED_DUMP}.")

    def run(self) -> None:
        sys.stdout.flush()
        input = str(self.query) + "koniec.\n"

        result = subprocess.run(
            ["./solution", TestGroup.ROUTES_FILE],
            input=input.encode(),
            capture_output=True,
        )
        output = result.stdout.decode()

        expected_trip_strs = list(map(str, self.query.solve(self.graph)))

        err = self._check_output(output, expected_trip_strs)
        if err:
            print(f"{BColors.FAIL}WA{BColors.ENDC}\n{err}")
            self._dump_test(output, expected_trip_strs)
            exit(1)


class TestGroup:
    ROUTES_FILE = "test_routes"

    def __init__(self, name: str, graph: Graph, queries: List[Query]) -> None:
        self.name = name
        self.graph = graph
        self.queries = queries

    def run(self) -> None:
        print(f"Running test {self.name}..", end=" ")
        sys.stdout.flush()

        graph_file = open(self.ROUTES_FILE, "w")
        graph_file.write(str(self.graph))
        graph_file.close()

        for i, query in enumerate(self.queries):
            progress = f"{i}/{len(self.queries)} "
            print(progress, end="")
            Test(f"{i}/{len(self.queries)}", self.graph, query).run()
            print("\b" * len(progress), end="")
            print(" " * len(progress), end="")
            print("\b" * len(progress), end="")

        print(f"{BColors.OKGREEN}OK{BColors.ENDC}")

        os.remove(self.ROUTES_FILE)


class RandomTestGroup(TestGroup):
    def __init__(
        self,
        name: str,
        vertices: int,
        edges: int,
        queries: int,
        seed: int = 0,
        one_way_p=0.5,
    ) -> None:
        self.name = name
        self.graph = RandomGraph(vertices, edges, seed=seed, one_way_p=one_way_p)
        print(self.graph)
        self.queries = random_queries(
            queries,
            list(self.graph._neighbours.keys()),
            [r.kind for r in self.graph.routes],
            seed=seed,
        )
        print(self.queries)


if __name__ == "__main__":
    # TestGroup(
    #     "sample",
    #     sample_graph,
    #     [
    #         Query("zakopane", "rusinowa", [Kind("rower")]),
    #         Query("zakopane", None, [Kind("gorska"), Length(Comp.LESS, 9)]),
    #         Query(None, None, [Kind("piesza")]),
    #         Query(
    #             "brzeziny", None, [Kind("gorska"), Kind("rower"), Length(Comp.LESS, 20)]
    #         ),
    #         Query(
    #             "gasienicowa", "gasienicowa", [Kind("gorska"), Length(Comp.LESS, 20)]
    #         ),
    #     ],
    # ).run()

    # TestGroup("nil_nil_nil", small_path, [Query(None, None, [])]).run()

    # TestGroup(
    #     "length conditions",
    #     cycle5,
    #     [
    #         Query(None, None, [Length(Comp.LESS, 3)]),
    #         Query(None, None, [Length(Comp.LESS_EQUAL, 3)]),
    #         Query(None, None, [Length(Comp.EQUAL, 3)]),
    #         Query(None, None, [Length(Comp.GREATER_EQUAL, 3)]),
    #         Query(None, None, [Length(Comp.GREATER, 3)]),
    #     ],
    # ).run()

    RandomTestGroup("random_small", vertices=4, edges=5, queries=20, seed=40).run()

    RandomTestGroup(
        "random_medium", vertices=6, edges=8, queries=50, seed=69, one_way_p=0.6
    ).run()

    RandomTestGroup(
        "random_big", vertices=10, edges=20, queries=200, seed=69, one_way_p=0.9
    ).run()
