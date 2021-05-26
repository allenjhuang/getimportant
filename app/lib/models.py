import graphene
from pydantic import BaseModel

from typing import Optional, List


class Request(BaseModel):
  text: str


class PhrasesREST(BaseModel):
  text: str
  rank: float
  count: Optional[int] = None
  sentences: Optional[List[str]] = None


class PhrasesGraphQL(graphene.ObjectType):
  text = graphene.String(required=True)
  rank = graphene.Float(required=True)
  count = graphene.Int()
  sentences = graphene.List(graphene.String)
